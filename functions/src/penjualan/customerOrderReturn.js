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
  const {products, invoiceId} = req.data;

  if (!products || products.length === 0) {
      return {success: false, message: "detail harus ada satu produk"};
  }
      
  if (!products.every((product) => {
    return product.product_id.trim() !== "";
  })) {
    return {success: false, message: "kode produk pada detail\n tidak boleh kosong"};
  }

  if (!products.every((product) => {
      return product.jumlah_pesanan > 0;
  })) {
      return {success: false, message: "jumlah pesanan pada detail harus di atas 0"};
  }

  if (!products.every((product) => {
      return product.jumlah_pengembalian > 0;
  })) {
      return {success: false, message: "jumlah pengembalian pada detail harus di atas 0"};
  }

  return {
    success: true,
  };
};
