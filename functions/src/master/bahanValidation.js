const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialModif = async (req) => {
  const {stok} = req.data;

  // Check if gajiLembur is provided, numeric, and not less than 0
  if (!stok || isNaN(stok) || stok < 0) {
    return {success: false, message: "Stok harus lebih besar dari 0"};
  }

  // Modifikasi berhasil
  return {success: true};
};
