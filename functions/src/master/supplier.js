/**
 * Fungsi untuk menambahkan supplier.
 *
 * @param {Object} req - Permintaan HTTP yang berisi data supplier.
 * @param {Object} req.data - Data supplier.
 * @param {string} req.data.telp - Nomor telepon supplier.
 * @param {string} req.data.telpKantor - Nomor telepon kantor supplier.
 * @param {string} req.data.email - Alamat email supplier.
 * @return {Object} Objek yang menyatakan apakah penambahan berhasil atau gagal.
 * @return {boolean} Objek.success - true jika penambahan berhasil, false jika gagal.
 * @return {string} Objek.message - Pesan jika terjadi kesalahan dalam penambahan.
 */
exports.supplierAdd = async (req) => {
  const { telp, telpKantor, email } = req.data;

  if (!/^\d+$/.test(telp)) {
    return { success: false, message: "Nomor telepon hanya bisa angka" };
  }

  if (!/^\d+$/.test(telpKantor)) {
    return { success: false, message: "Nomor telepon kantor hanya bisa angka" };
  }

  if (!isValidEmail(email)) {
    return { success: false, message: "Format email salah" };
  }

  return {
    success: true,
  };
};

// eslint-disable-next-line require-jsdoc
function isValidEmail(email) {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  return emailRegex.test(email);
}
