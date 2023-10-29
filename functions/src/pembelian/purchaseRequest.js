const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.purchaseReqValidation = async (req) => {
  const { jumlah } = req.data;

  if (!jumlah || isNaN(jumlah) || jumlah < 0) {
    return { success: false, message: "Jumlah harus lebih besar dari 0" };
  }

  // Modifikasi berhasil
  return {
    success: true,
  };
};
