const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.mesinValidation = async (req) => {
  const {kapasitasProduksi, nama, nomorSeri, tahunDapat, tahunProduksi, supplier} = req.data;

  // Check if nama is provided and not empty
  if (!nama || nama.trim() === "") {
    return {success: false, message: "nama tidak boleh kosong"};
  }

  if (!nomorSeri || nomorSeri.trim() === "") {
    return {success: false, message: "nomor seri tidak boleh kosong"};
  }

  if (!supplier || supplier.trim() === "") {
    return {success: false, message: "supplier tidak boleh kosong"};
  }

  if (isNaN(kapasitasProduksi) || kapasitasProduksi <= 0) {
    return {success: false, message: `kapasitas produksi harus lebih besar dari 0`};
  }

  if (isNaN(tahunDapat) || tahunDapat <= 0) {
    return {success: false, message: `tahun perolehan harus lebih besar dari 0`};
  }

  if (isNaN(tahunProduksi) || tahunProduksi <= 0) {
    return {success: false, message: `tahun produksi harus lebih besar dari 0`};
  }

  // Modifikasi berhasil
  return {success: true};
};
