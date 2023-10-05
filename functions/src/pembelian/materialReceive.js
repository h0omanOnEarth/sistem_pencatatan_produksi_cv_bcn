const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialRecValidation = async (req) => {
  const {jumlahPermintaan, jumlahDiterima, materialId, purchaseReqId} = req.data;

  if (!jumlahPermintaan || isNaN(jumlahPermintaan) || jumlahPermintaan < 0) {
    return { success: false, message: "jumlah permintaan harus lebih besar dari 0" };
  }

  if (!jumlahDiterima || isNaN(jumlahDiterima) || jumlahDiterima < 0) {
    return { success: false, message: "jumlah diterima harus lebih besar dari 0" };
  }
    
  // Modifikasi berhasil
  return {
    success: true,
  };
};
