const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.invoiceValidation = async (req) => {
  const { products, totalProduk, totalHarga } = req.data;

  if (!products || products.length === 0) {
    return { success: false, message: "minimal harus ada satu produk" };
  }

  if (!totalProduk || isNaN(totalProduk) || totalProduk < 0) {
    return { success: false, message: "total produk harus lebih besar dari 0" };
  }

  if (!totalHarga || isNaN(totalHarga) || totalHarga < 0) {
    return { success: false, message: "total harga harus lebih besar dari 0" };
  }

  return {
    success: true,
  };
};