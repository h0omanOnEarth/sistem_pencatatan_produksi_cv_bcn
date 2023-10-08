const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialTransformValidate = async (req) => {
    const {jumlahBarangGagal, jumlahHasil, totalHasil} = req.data;

    if (!jumlahBarangGagal || isNaN(jumlahBarangGagal) || jumlahBarangGagal < 0) {
        return {success: false, message: "jumlah barang gagal harus lebih besar dari 0"};
    }

    if (!jumlahHasil || isNaN(jumlahHasil) || jumlahHasil < 0) {
        return {success: false, message: "jumlah berhasil harus lebih besar dari 0"};
    }

    if (!totalHasil || isNaN(totalHasil) || totalHasil < 0) {
        return {success: false, message: "total harus lebih besar dari 0"};
    }

    return {
        success: true,
    };
}