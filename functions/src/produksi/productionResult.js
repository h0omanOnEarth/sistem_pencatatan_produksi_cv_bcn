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
      message: "total hasil produksi harus lebih besar dari 0",
    };
  }

  if (!jumlahBerhasil || jumlahBerhasil <= 0) {
    return {
      success: false,
      message: "jumlah berhasil harus lebih besar dari 0",
    };
  }

  if (!jumlahCacat || jumlahCacat <= 0) {
    return {
      success: false,
      message: "jumlah cacat harus lebih besar dari 0",
    };
  }

  if (!waktu || waktu <= 0) {
    return {
      success: false,
      message: "waktu produksi harus lebih besar dari 0",
    };
  }

  return {
    success: true,
  };
};
