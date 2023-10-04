const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.purchaseOrderValidation = async (req) => {
  const {hargaSatuan, jumlah, total} = req.data;

  // Check if gajiLembur is provided, numeric, and not less than 0
  if (!hargaSatuan || isNaN(hargaSatuan) || hargaSatuan < 0) {
    return { success: false, message: "harga satuan harus lebih besar dari 0" };
  }

  // Check if gajiLembur is provided, numeric, and not less than 0
  if (!jumlah || isNaN(jumlah) || jumlah < 0) {
    return { success: false, message: "jumlah satuan harus lebih besar dari 0" };
  }

  // Check if gajiLembur is provided, numeric, and not less than 0
  if (!total || isNaN(total) || total < 0) {
    return { success: false, message: "total satuan harus lebih besar dari 0" };
  }

  // Modifikasi berhasil
  return {
    success: true,
  };
};
