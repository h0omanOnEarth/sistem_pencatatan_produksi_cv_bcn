const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

async function generateNextNotificationId() {
    const notificationsRef = admin.firestore().collection("notifications");
    const snapshot = await notificationsRef.get();
    const existingIds = snapshot.docs.map((doc) => doc.id);
    let notificationCount = 1;
  
    while (true) {
      const nextNotificationId = `NOTIF${notificationCount.toString().padStart(5, '0')}`;
      if (!existingIds.includes(nextNotificationId)) {
        return nextNotificationId;
      }
      notificationCount++;
    }
}

exports.suratJalanValidation = async (req) => {
    const {products, totalPcs, deliveryOrderId, mode} = req.data;

    if (!products || products.length === 0) {
        return {success: false, message: "Detail harus ada satu produk"};
    }
      
    if (!products.every((product) => {
      return product.product_id.trim() !== "";
    })) {
      return {success: false, message: "Kode produk pada detail\n tidak boleh kosong"};
    }

    if (!products.every((product) => {
        return product.jumlah_pengiriman > 0;
    })) {
        return {success: false, message: "Jumlah pengiriman pada detail harus di atas 0"};
    }

    if (!products.every((product) => {
        return product.jumlah_pengiriman_dus > 0;
    })) {
        return {success: false, message: "Jumlah pengiriman dus pada detail harus di atas 0"};
    }

    if (!totalPcs || isNaN(totalPcs) || totalPcs < 0) {
        return {success: false, message: "Total pcs lebih besar dari 0"};
    }

    try {
        // Periksa status_pesanan_pengiriman pada delivery_orders
        const deliveryOrdersRef = admin.firestore().collection("delivery_orders").doc(deliveryOrderId);
        const deliveryOrderDoc = await deliveryOrdersRef.get();
        const statusPesananPengiriman = deliveryOrderDoc.data().status_pesanan_pengiriman;

        if(mode=='add'){
            if (statusPesananPengiriman === "Selesai") {
                return {
                    success: false,
                    message: "Status pesanan pengiriman sudah 'Selesai'",
                };
            }
        }

        // Periksa stok produk pada koleksi 'products'
        const productsRef = admin.firestore().collection("products");
        const notificationsRef = admin.firestore().collection("notifications");
        const detailDeliveryOrdersRef = deliveryOrdersRef.collection("detail_delivery_orders");

        for (const product of products) {
            const productId = product.product_id;
            const jumlahPengiriman = product.jumlah_pengiriman;
            const jumlahPengirimanDus = product.jumlah_pengiriman_dus;

            // Hitung jumlah total dari subkoleksi detail_delivery_orders
            const totalDetailDelivery = await detailDeliveryOrdersRef
                .where("product_id", "==", productId)
                .get()
                .then((snapshot) =>
                    snapshot.docs.reduce((total, doc) => total + doc.data().jumlah, 0)
                );
    
            if (jumlahPengiriman > totalDetailDelivery) {
                return {
                    success: false,
                    message: `Jumlah pengiriman produk ${productId} melebihi jumlah dalam detail delivery orders`,
                };
            }
    
            if (jumlahPengirimanDus * 2000 > totalDetailDelivery) {
                return {
                    success: false,
                    message: `Jumlah pengiriman dus produk ${productId} melebihi jumlah dalam detail delivery orders (dalam dus)`,
                };
            }

            const productQuerySnapshot = await productsRef.where("id", "==", productId).get();

            if (!productQuerySnapshot.empty) {
                const productDocData = productQuerySnapshot.docs[0].data();
                const stokProduk = productDocData.stok;

                if (stokProduk - jumlahPengiriman < 0) {
                    const notificationId = await generateNextNotificationId();
                    // Jika stok tidak mencukupi, push notifikasi
                    const notifDoc = {
                        id: notificationId,
                        pesan: `Stok Produk ${productId} habis`,
                        posisi: "Produksi",
                        status: 1,
                        created_at: admin.firestore.FieldValue.serverTimestamp(),
                    };

                    await notificationsRef.add(notifDoc);

                    return {
                        success: false,
                        message: `Stok Produk ${productId} tidak mencukupi, pengiriman tidak dapat dilakukan`,
                    };
                }
            }
        }

        // Jika semua produk tersedia, kurangi stok dan ubah status_pesanan_pengiriman
        for (const product of products) {
            const productId = product.product_id;
            const jumlahPengiriman = product.jumlah_pengiriman;

            const productQuerySnapshot = await productsRef.where("id", "==", productId).get();

            if (!productQuerySnapshot.empty) {
                const productDocRef = productQuerySnapshot.docs[0].ref;
                const currentStock = (await productDocRef.get()).data().stok;

                // Kurangi stok produk
                await productDocRef.update({ stok: currentStock - jumlahPengiriman });
            }
        }

        // Ubah status_pesanan_pengiriman pada delivery_orders menjadi 'Selesai'
        await deliveryOrdersRef.update({ status_pesanan_pengiriman: "Selesai" });

        return {
            success: true,
        };
    } catch (error) {
        console.error("Error validating surat jalan:", error);
        return { success: false, message: "Terjadi kesalahan dalam validasi surat jalan" };
    }
}