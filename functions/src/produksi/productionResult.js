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
  const {total, jumlahBerhasil, jumlahCacat, waktu, materialUsageId} = req.data;

  if (!total || total <= 0) {
    return {
      success: false,
      message: "Total hasil produksi harus lebih besar dari 0",
    };
  }

  if (!jumlahBerhasil || jumlahBerhasil <= 0) {
    return {
      success: false,
      message: "Jumlah berhasil harus lebih besar dari 0",
    };
  }

  if (!jumlahCacat || jumlahCacat <= 0) {
    return {
      success: false,
      message: "Jumlah cacat harus lebih besar dari 0",
    };
  }

  if (!waktu || waktu <= 0) {
    return {
      success: false,
      message: "Waktu produksi harus lebih besar dari 0",
    };
  }

  try {
    // Dapatkan material usage yang sesuai dengan materialUsageId
    const materialUsageRef = admin.firestore().collection("material_usages").doc(materialUsageId);
    const materialUsageDoc = await materialUsageRef.get();

    // Periksa status_mu pada materialUsage
    const statusMu = materialUsageDoc.data().status_mu;

    if (statusMu !== "Selesai") {
      return {
        success: false,
        message: `Material usage belum 'Selesai', status saat ini: ${statusMu}`,
      };
    }

    // Periksa batch pada materialUsage
    const batch = materialUsageDoc.data().batch;

    if (batch !== "Pencetakan") {
      return {
        success: false,
        message: "Batch harus 'Pencetakan'",
      };
    }

    // Periksa apakah production_results sudah ada untuk materialUsageId
    const productionResultsQuery = await admin
      .firestore()
      .collection("production_results")
      .where("material_usage_id", "==", materialUsageId)
      .get();

    if (!productionResultsQuery.empty) {
      return {
        success: false,
        message: "Sudah ada pencatatan hasil produksi untuk nomor penggunaan bahan ini",
      };
    }

    // Periksa status produksi pada materialUsage
    const productionOrderId = materialUsageDoc.data().production_order_id;
    const productionOrderRef = admin.firestore().collection("production_orders").doc(productionOrderId);
    const productionOrderDoc = await productionOrderRef.get();
    const productionOrderStatus = productionOrderDoc.data().status_pro;

    if (productionOrderStatus === "Selesai") {
      return {
        success: false,
        message: "Status perintah produksi dalam nomor penggunana bahan ini sudah 'Selesai'",
      };
    }

    // Jika semua pemeriksaan berhasil, ubah status produksi menjadi 'Selesai'
    await productionOrderRef.update({status: "Selesai"});

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating production result:", error);
    return { success: false, message: "Terjadi kesalahan dalam validasi hasil produksi" };
  }
};
