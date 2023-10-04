const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.dlohValidation = async (req) => {
  const {
    jumlahTenagaKerja,
    jumlahJamTenagaKerja,
    biayaTenagaKerja,
    upahTenagaKerjaPerjam,
    subtotal,
  } = req.data;

  if (!jumlahTenagaKerja || jumlahTenagaKerja <= 0) {
    return {
      success: false,
      message: "Jumlah tenaga kerja harus lebih besar dari 0",
    };
  }

  if (!jumlahJamTenagaKerja || jumlahJamTenagaKerja <= 0) {
    return {
      success: false,
      message: "Jumlah jam tenaga kerja harus lebih besar dari 0",
    };
  }

  if (!biayaTenagaKerja || biayaTenagaKerja <= 0) {
    return {
      success: false,
      message: "Biaya tenaga kerja harus lebih besar dari 0",
    };
  }

  if (!upahTenagaKerjaPerjam || upahTenagaKerjaPerjam <= 0) {
    return {
      success: false,
      message: "Upah tenaga kerja per jam harus lebih besar dari 0",
    };
  }

  if (!subtotal || subtotal <= 0) {
    return {
      success: false,
      message: "Subtotal harus lebih besar dari 0",
    };
  }

  return {
    success: true,
  };
};
