const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialUsageValidation = async (req) => {
  const { materials, materialRequestId, productionOrderId, batch, mode } =
    req.data;

  // Pemeriksaan apakah productionOrderId sama dengan production_order_id di koleksi material_requests
  const materialRequestSnapshot = await admin
    .firestore()
    .collection("material_requests")
    .doc(materialRequestId)
    .get();
  if (materialRequestSnapshot.exists) {
    const materialRequestData = materialRequestSnapshot.data();
    if (materialRequestData.production_order_id !== productionOrderId) {
      return {
        success: false,
        message: `Nomor perintah produksi tidak sesuai dengan nomor permintaan bahan, seharusnya ${materialRequestData.production_order_id}`,
      };
    }
  } else {
    return { success: false, message: "Material Request tidak ditemukan" };
  }

  // Periksa apakah material request sudah ada pada koleksi material_transfers dengan status_mtr "Selesai"
  const materialTransferQuery = await admin
    .firestore()
    .collection("material_transfers")
    .where("material_request_id", "==", materialRequestId)
    .where("status_mtr", "==", "Selesai")
    .get();

  if (materialTransferQuery.empty) {
    return {
      success: false,
      message: "Bahan-bahan pada material request belum dipindahkan",
    };
  }

  if (mode == "add") {
    // Periksa apakah ada material_transfer yang memiliki production_order_id dan batch yang sama
    const materialUsagesQuery = await admin
      .firestore()
      .collection("material_usages")
      .where("production_order_id", "==", productionOrderId)
      .where("batch", "==", batch)
      .where("material_request_id", "==", materialRequestId)
      .get();

    if (!materialUsagesQuery.empty) {
      return {
        success: false,
        message:
          "Material usage dengan production_order_id, material_request_id, dan batch yang sama sudah ada",
      };
    }
  }

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
      return material.jumlah > 0;
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

  // Periksa apakah batch sesuai dengan batch pada subkoleksi detail_material_requests
  const detailMaterialRequestRef = admin
    .firestore()
    .collection("material_requests")
    .doc(materialRequestId)
    .collection("detail_material_requests");
  const detailMaterialRequestQuery = await detailMaterialRequestRef
    .where("batch", "==", batch)
    .get();

  if (detailMaterialRequestQuery.empty) {
    return {
      success: false,
      message: "Batch tidak sesuai dengan Material Request",
    };
  }

  // Pemeriksaan apakah material.material_id ada yang cocok dengan material_id pada detailMaterialRequestRef
  const detailMaterialRequests = detailMaterialRequestQuery.docs.map((doc) =>
    doc.data(),
  );
  const invalidMaterialIds = materials.filter((material) => {
    return !detailMaterialRequests.some(
      (detailMaterial) => detailMaterial.material_id === material.material_id,
    );
  });

  if (invalidMaterialIds.length > 0) {
    const invalidMaterialIdList = invalidMaterialIds
      .map((material) => material.material_id)
      .join(", ");
    return {
      success: false,
      message: `Material_id tidak valid: ${invalidMaterialIdList}`,
    };
  }

  const detailMaterialRequestsQueryQty = await detailMaterialRequestRef.get();
  const materialIdQuantities = {};
  const materialIdUnits = {}; // Menyimpan satuan material berdasarkan material_id

  detailMaterialRequestsQueryQty.forEach((doc) => {
    const detailMaterialRequestData = doc.data();
    const materialId = detailMaterialRequestData.material_id;
    const quantity = detailMaterialRequestData.jumlah_bom;
    const unit = detailMaterialRequestData.satuan;

    materialIdQuantities[materialId] = quantity;
    materialIdUnits[materialId] = unit;
  });

  for (const material of materials) {
    const materialId = material.material_id;
    const quantityInMaterials = material.jumlah;
    const quantityInDetailMaterialRequests = materialIdQuantities[materialId];
    const unitInMaterials = material.satuan;
    const unitInDetailMaterialRequests = materialIdUnits[materialId];

    if (quantityInMaterials > quantityInDetailMaterialRequests) {
      return {
        success: false,
        message: `Jumlah ${materialId} melebihi yang tersedia dalam detail_material_requests,\nseharusnya ${quantityInDetailMaterialRequests}`,
      };
    }

    if (unitInMaterials !== unitInDetailMaterialRequests) {
      return {
        success: false,
        message: `Satuan ${materialId} tidak sesuai dengan yang ada dalam detail_material_requests, seharusnya ${unitInDetailMaterialRequests}`,
      };
    }
  }

  // Modifikasi berhasil
  return {
    success: true,
  };
};
