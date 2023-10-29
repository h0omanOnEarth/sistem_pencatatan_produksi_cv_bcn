const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.productValidation = async (req) => {
  const { berat, harga, dimensi, ketebalan, stok } = req.data;

  if (isNaN(berat) || berat <= 0) {
    return { success: false, message: `Berat harus lebih besar dari 0` };
  }

  if (isNaN(harga) || harga <= 0) {
    return { success: false, message: `Harga harus lebih besar dari 0` };
  }

  if (isNaN(dimensi) || dimensi <= 0) {
    return { success: false, message: `Dimensi harus lebih besar dari 0` };
  }

  if (isNaN(ketebalan) || ketebalan <= 0) {
    return { success: false, message: `Ketebalan harus lebih besar dari 0` };
  }

  if (isNaN(stok) || stok <= 0) {
    return { success: false, message: `Stok harus lebih besar dari 0` };
  }

  // Modifikasi berhasil
  return { success: true };
};
