const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.customerOrderValidation = async (req) => {
  const { products, totalProduk, totalHarga } = req.data;

  if (!products || products.length === 0) {
    return { success: false, message: "Minimal harus ada satu produk" };
  }

  // Pemeriksaan jika setiap elemen memenuhi kriteria
  if (
    !products.every((product) => {
      return product.product_id.trim() !== "";
    })
  ) {
    return { success: false, message: "Product_id tidak boleh kosong" };
  }

  if (
    !products.every((product) => {
      return product.jumlah > 0;
    })
  ) {
    return { success: false, message: "Jumlah pada detail harus di atas 0" };
  }

  if (
    !products.every((product) => {
      return product.satuan.trim !== "";
    })
  ) {
    return { success: false, message: "Satuan tidak boleh kosong" };
  }

  if (
    !products.every((product) => {
      return product.harga_satuan > 0;
    })
  ) {
    return {
      success: false,
      message: "Harga satuan pada detail harus di atas 0",
    };
  }

  if (
    !products.every((product) => {
      return product.subtotal > 0;
    })
  ) {
    return { success: false, message: "Subtotal pada detail harus di atas 0" };
  }

  if (!totalProduk || isNaN(totalProduk) || totalProduk < 0) {
    return { success: false, message: "Total produk harus lebih besar dari 0" };
  }

  if (!totalHarga || isNaN(totalHarga) || totalHarga < 0) {
    return { success: false, message: "Total harga harus lebih besar dari 0" };
  }

  return {
    success: true,
  };
};
