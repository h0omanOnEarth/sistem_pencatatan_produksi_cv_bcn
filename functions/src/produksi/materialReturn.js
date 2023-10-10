const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialReturnValidation = async (req) => {
  const { materials, materialUsageId} = req.data;

  if (!materials || materials.length === 0) {
    return { success: false, message: "Minimal harus ada satu bahan/material" };
  }

  // Pemeriksaan jika setiap elemen memenuhi kriteria
  if (!materials.every((material) => {
    return material.material_id.trim() !== "";
  })) {
    return { success: false, message: "Material_id tidak boleh kosong" };
  }

  if (!materials.every((material) => {
    return material.jumlah > 0;
  })) {
    return { success: false, message: "Jumlah pada detail harus di atas 0" };
  }

  if (!materials.every((material) => {
    return material.satuan.trim!=="";
  })) {
    return { success: false, message: "Satuan tidak boleh kosong" };
  }

  return {
    success: true,
  };
};
