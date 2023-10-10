const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.productionResValidate = async (req) => {
  const {total, jumlahBerhasil, jumlahCacat, waktu} = req.data;

  if (!total || total <= 0) {
    return {
      success: false,
      message: "Total hasil produksi harus lebih besar dari 0",
    };
  }

  if (!jumlahBerhasil || jumlahBerhasil <= 0) {
    return {
      success: false,
      message: "Jumlah berhasil harus lebih besar dari 0",
    };
  }

  if (!jumlahCacat || jumlahCacat <= 0) {
    return {
      success: false,
      message: "Jumlah cacat harus lebih besar dari 0",
    };
  }

  if (!waktu || waktu <= 0) {
    return {
      success: false,
      message: "Waktu produksi harus lebih besar dari 0",
    };
  }

  return {
    success: true,
  };
};
