const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.itemReceiveValidation = async (req) => {
  const { products, productionConfirmationId, mode } = req.data;
  log(products);

  if (!products || products.length === 0) {
    return { success: false, message: "Detail harus ada satu produk" };
  }

  if (
    !products.every((product) => {
      return product.product_id.trim() !== "";
    })
  ) {
    return {
      success: false,
      message: "Kode produk pada detail\n tidak boleh kosong",
    };
  }

  if (
    !products.every((product) => {
      return product.jumlah_pcs > 0;
    })
  ) {
    return { success: false, message: "Jumlah pada detail harus di atas 0" };
  }

  try {
    // Periksa status_prc pada production_confirmations
    const productionConfirmationRef = admin
      .firestore()
      .collection("production_confirmations")
      .doc(productionConfirmationId);
    const productionConfirmationDoc = await productionConfirmationRef.get();
    const statusPrc = productionConfirmationDoc.data().status_prc;

    if (mode == "add") {
      if (statusPrc === "Selesai") {
        return {
          success: false,
          message: "Status konfirmasi produksi sudah 'Selesai'",
        };
      }
    }

    // Dapatkan subkoleksi detail_production_confirmations
    const detailProductionConfirmationsRef =
      productionConfirmationRef.collection("detail_production_confirmations");
    const detailProductionConfirmationsQuery =
      await detailProductionConfirmationsRef.get();

    const productsRef = admin.firestore().collection("products");

    // Ambil product_id dan jumlah_konfirmasi dari subkoleksi dan tambahkan ke stok produk
    detailProductionConfirmationsQuery.forEach(async (doc) => {
      const productData = doc.data();
      const productId = productData.product_id;
      const jumlahKonfirmasi = productData.jumlah_konfirmasi;

      // Cari produk dengan product_id
      const productQuerySnapshot = await productsRef
        .where("id", "==", productId)
        .get();

      if (!productQuerySnapshot.empty) {
        const productDocRef = productQuerySnapshot.docs[0].ref;
        const currentStock = (await productDocRef.get()).data().stok;

        // Perbarui stok produk sesuai jumlah_konfirmasi
        await productDocRef.update({ stok: currentStock + jumlahKonfirmasi });
      }
    });

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating item receive:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi penerimaan item",
    };
  }
};
