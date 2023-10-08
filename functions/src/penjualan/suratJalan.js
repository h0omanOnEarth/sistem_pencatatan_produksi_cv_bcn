const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.suratJalanValidation = async (req) => {
    const {products, totalPcs} = req.data;

    if (!products || products.length === 0) {
        return {success: false, message: "detail harus ada satu produk"};
    }
      
    if (!products.every((product) => {
      return product.product_id.trim() !== "";
    })) {
      return {success: false, message: "kode produk pada detail\n tidak boleh kosong"};
    }

    if (!products.every((product) => {
        return product.jumlah_pengiriman > 0;
    })) {
        return {success: false, message: "jumlah pengiriman pada detail harus di atas 0"};
    }

    if (!products.every((product) => {
        return product.jumlah_pengiriman_dus > 0;
    })) {
        return {success: false, message: "jumlah pengiriman dus pada detail harus di atas 0"};
    }

    if (!totalPcs || isNaN(totalPcs) || totalPcs < 0) {
        return {success: false, message: "total pcs lebih besar dari 0"};
    }

    return {
        success: true,
    };
}