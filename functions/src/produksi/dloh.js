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
    materialUsageId,
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

  try {
    // Dapatkan status_mu dari dokumen materialUsageId di koleksi material_usages
    const materialUsageRef = admin
      .firestore()
      .collection("material_usages")
      .doc(materialUsageId);
    const materialUsageDoc = await materialUsageRef.get();

    // Periksa status_mu pada materialUsageId
    const statusMu = materialUsageDoc.data().status_mu;

    if (statusMu !== "Selesai") {
      return {
        success: false,
        message: `Material usage belum selesai, status saat ini: ${statusMu}`,
      };
    }

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating dloh:", error);
    return { success: false, message: "Terjadi kesalahan dalam validasi dloh" };
  }
};
