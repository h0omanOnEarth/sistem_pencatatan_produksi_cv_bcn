const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.deliveryOrderValidate = async (req) => {
  const { products, customerOrderId, totalProduk, totalHarga } = req.data;

  if (!products || products.length === 0) {
    return { success: false, message: "Minimal harus ada satu produk" };
  }

  if (
    !products.every((product) => {
      return product.product_id.trim() !== "";
    })
  ) {
    return { success: false, message: "Product_id tidak boleh kosong" };
  }

  if (
    !products.every((product) => {
      return product.jumlah > 0;
    })
  ) {
    return { success: false, message: "Jumlah pada detail harus di atas 0" };
  }

  if (
    !products.every((product) => {
      return product.satuan.trim !== "";
    })
  ) {
    return { success: false, message: "Satuan tidak boleh kosong" };
  }

  if (
    !products.every((product) => {
      return product.harga_satuan > 0;
    })
  ) {
    return {
      success: false,
      message: "Harga satuan pada detail harus di atas 0",
    };
  }

  if (
    !products.every((product) => {
      return product.subtotal > 0;
    })
  ) {
    return { success: false, message: "Subtotal pada detail harus di atas 0" };
  }

  if (!totalProduk || isNaN(totalProduk) || totalProduk < 0) {
    return { success: false, message: "Total produk harus lebih besar dari 0" };
  }

  if (!totalHarga || isNaN(totalHarga) || totalHarga < 0) {
    return { success: false, message: "Total harga harus lebih besar dari 0" };
  }

  try {
    // Periksa status_co pada customerOrderId
    const customerOrdersRef = admin
      .firestore()
      .collection("customer_orders")
      .doc(customerOrderId);
    const customerOrderDoc = await customerOrdersRef.get();
    const statusCo = customerOrderDoc.data().status_co;

    if (statusCo === "Selesai") {
      return {
        success: false,
        message: "Status pesanan pelanggan sudah 'Selesai'",
      };
    }

    await customerOrdersRef.update({ status_pesanan: "Selesai" });

    // Periksa satuan pada products
    const productsRef = admin.firestore().collection("products");

    for (const product of products) {
      const productId = product.product_id;
      const satuan = product.satuan;

      const productQuerySnapshot = await productsRef
        .where("id", "==", productId)
        .get();

      if (!productQuerySnapshot.empty) {
        const productDocData = productQuerySnapshot.docs[0].data();
        const satuanProduk = productDocData.satuan;

        if (satuan !== satuanProduk) {
          return {
            success: false,
            message: `Satuan produk ${productId} tidak sesuai dengan satuan yang diperoleh dari koleksi 'products',\nseharusnya ${satuanProduk}`,
          };
        }
      }
    }

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating delivery order:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi pesanan pengiriman",
    };
  }
};
