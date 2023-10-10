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
    return {success: false, message: "Nama tidak boleh kosong"};
  }

  if (!nomorSeri || nomorSeri.trim() === "") {
    return {success: false, message: "Nomor seri tidak boleh kosong"};
  }

  if (!supplier || supplier.trim() === "") {
    return {success: false, message: "Supplier tidak boleh kosong"};
  }

  if (isNaN(kapasitasProduksi) || kapasitasProduksi <= 0) {
    return {success: false, message: `Kapasitas produksi harus lebih besar dari 0`};
  }

  if (isNaN(tahunDapat) || tahunDapat <= 0) {
    return {success: false, message: `Tahun perolehan harus lebih besar dari 0`};
  }

  if (isNaN(tahunProduksi) || tahunProduksi <= 0) {
    return {success: false, message: `Tahun produksi harus lebih besar dari 0`};
  }

  // Modifikasi berhasil
  return {success: true};
};
