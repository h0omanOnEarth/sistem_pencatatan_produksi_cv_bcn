const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialRequestValidation = async (req) => {
  const { materials, productionOrderId } = req.data;

  if (!materials || materials.length === 0) {
    return { success: false, message: "Minimal harus ada satu bahan/material" };
  }

  // Pemeriksaan jika setiap elemen memenuhi kriteria
  if (
    !materials.every((material) => {
      return material.material_id.trim() !== "";
    })
  ) {
    return { success: false, message: "Material_id tidak boleh kosong" };
  }

  if (
    !materials.every((material) => {
      return material.jumlah_bom > 0;
    })
  ) {
    return { success: false, message: "Jumlah pada detail harus di atas 0" };
  }

  if (
    !materials.every((material) => {
      return material.satuan.trim !== "";
    })
  ) {
    return { success: false, message: "Satuan tidak boleh kosong" };
  }

  try {
    // Periksa status productionOrderId
    const productionOrderRef = admin
      .firestore()
      .collection("production_orders")
      .doc(productionOrderId);
    const productionOrderDoc = await productionOrderRef.get();

    if (!productionOrderDoc.exists) {
      return { success: false, message: "Production order tidak ditemukan" };
    }

    const productionOrderData = productionOrderDoc.data();

    if (productionOrderData.status_pro == "Selesai") {
      return { success: false, message: "Production order telah 'Selesai'" };
    }

    return { success: true };
  } catch (error) {
    console.error("Error validating material request:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi material request",
    };
  }
};
