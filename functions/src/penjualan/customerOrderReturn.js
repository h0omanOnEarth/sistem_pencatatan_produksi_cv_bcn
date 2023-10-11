const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.customerOrderReturnValidation = async (req) => {
  const {products, invoiceId, mode} = req.data;

  if (!products || products.length === 0) {
      return {success: false, message: "Detail harus ada satu produk"};
  }
      
  if (!products.every((product) => {
    return product.product_id.trim() !== "";
  })) {
    return {success: false, message: "Kode produk pada detail\n tidak boleh kosong"};
  }

  if (!products.every((product) => {
      return product.jumlah_pesanan > 0;
  })) {
      return {success: false, message: "Jumlah pesanan pada detail harus di atas 0"};
  }

  if (!products.every((product) => {
      return product.jumlah_pengembalian > 0;
  })) {
      return {success: false, message: "Jumlah pengembalian pada detail harus di atas 0"};
  }

  if (!products.every((product) => {
    return product.jumlah_pesanan >= product.jumlah_pengembalian;
  })) {
      return {success: false, message: "Jumlah pesanan tidak boleh lebih kecil daripada jumlah pengembalian pada detail"};
  }

  try {
    // Periksa status_fk pada invoice
    const invoiceRef = admin.firestore().collection("invoices").doc(invoiceId);
    const invoiceDoc = await invoiceRef.get();
    const statusFk = invoiceDoc.data().status_fk;

    if(mode=='add'){
      if (statusFk !== "Selesai") {
        return { success: false, message: "Invoice belum selesai" };
      }
    }

     // Jika validasi sukses, kembalikan stok produk
     for (const product of products) {
      const productId = product.product_id;
      const jumlahPengembalian = product.jumlah_pengembalian;

      const productRef = admin.firestore().collection("products").doc('productXXX');
      const productDoc = await productRef.get();
      const currentStock = productDoc.data().stok;

      // Update stok produk
      await productRef.update({ stok: currentStock + jumlahPengembalian });
    }

    return {
      success: true,
    };

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating customer order return:", error);
    return { success: false, message: "Terjadi kesalahan dalam validasi pengembalian pesanan pelanggan" };
  }
};
