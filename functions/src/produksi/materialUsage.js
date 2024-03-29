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
  let totalMaterial = 0;

  // Pemeriksaan apakah productionOrderId sama dengan production_order_id di koleksi production_orders
  const productionOrderSnapshot = await admin
    .firestore()
    .collection("production_orders")
    .doc(productionOrderId)
    .get();

  if (productionOrderSnapshot.exists) {
    const productionOrderData = productionOrderSnapshot.data();
    if (productionOrderData.id !== productionOrderId) {
      return {
        success: false,
        message: `Nomor perintah produksi tidak sesuai dengan nomor permintaan bahan, seharusnya ${productionOrderData.id}`,
      };
    }
  } else {
    return { success: false, message: "Production Order tidak ditemukan" };
  }

  // Periksa apakah material request sudah ada pada koleksi material_transfers dengan status_mtr "Selesai"
  const materialTransferQuery = await admin
    .firestore()
    .collection("material_transfers")
    .where("material_request_id", "==", materialRequestId)
    .where("status_mtr", "==", "Selesai")
    .where("status", "==", 1)
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

  // Periksa apakah batch sesuai dengan batch pada subkoleksi detail_production_orders
  const detailProductionOrderRef = admin
    .firestore()
    .collection("production_orders")
    .doc(productionOrderId)
    .collection("detail_production_orders");

  const detailProductionOrderQuery = await detailProductionOrderRef
    .where("batch", "==", batch)
    .get();

  if (batch != "Sheet") {
    if (detailProductionOrderQuery.empty) {
      return {
        success: false,
        message: "Batch tidak sesuai dengan Production Order",
      };
    }
  }

  // Pemeriksaan apakah material.material_id ada yang cocok dengan material_id pada detailProductionOrderRef
  const detailProductionOrders = detailProductionOrderQuery.docs.map((doc) =>
    doc.data()
  );

  const invalidMaterialIds = materials.filter((material) => {
    return !detailProductionOrders.some(
      (detailProduction) =>
        detailProduction.material_id === material.material_id
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

  const detailProductionOrdersQueryQty = await detailProductionOrderRef.get();
  const materialIdQuantities = {};
  const materialIdUnits = {}; // Menyimpan satuan material berdasarkan material_id

  detailProductionOrdersQueryQty.forEach((doc) => {
    const detailProductionOrderData = doc.data();
    const materialId = detailProductionOrderData.material_id;
    const quantity = detailProductionOrderData.jumlah_bom;
    const unit = detailProductionOrderData.satuan;

    materialIdQuantities[materialId] = quantity;
    materialIdUnits[materialId] = unit;
  });

  for (const material of materials) {
    const materialId = material.material_id;
    const quantityInMaterials = material.jumlah;
    const quantityInDetailProductionOrders = materialIdQuantities[materialId];
    const unitInMaterials = material.satuan;
    const unitInDetailProductionOrders = materialIdUnits[materialId];
    totalMaterial = totalMaterial + material.jumlah;

    if (quantityInMaterials > quantityInDetailProductionOrders) {
      return {
        success: false,
        message: `Jumlah ${materialId} melebihi yang tersedia dalam detail_production_orders,\nseharusnya ${quantityInDetailProductionOrders}`,
      };
    }

    if (unitInMaterials !== unitInDetailProductionOrders) {
      return {
        success: false,
        message: `Satuan ${materialId} tidak sesuai dengan yang ada dalam detail_production_orders, seharusnya ${unitInDetailProductionOrders}`,
      };
    }
  }

  if (mode == "add" && batch == "Pencampuran") {
    const materialRef = admin
      .firestore()
      .collection("materials")
      .where("id", "==", "material011");
    const materialQuery = await materialRef.get();
    if (!materialQuery.empty) {
      const materialDoc = materialQuery.docs[0];
      const materialData = materialDoc.data();
      const stokSaatIni = materialData.stok || 0;

      const stokBaru = stokSaatIni + totalMaterial;
      // Update stok di dokumen 'materials'
      await materialDoc.ref.update({ stok: stokBaru });
    }
  }

  if (mode == "add" && batch == "Sheet") {
    const materialRef = admin
      .firestore()
      .collection("materials")
      .where("id", "==", "material012");
    const materialQuery = await materialRef.get();
    if (!materialQuery.empty) {
      const materialDoc = materialQuery.docs[0];
      const materialData = materialDoc.data();
      const stokSaatIni = materialData.stok || 0;

      const stokBaru = stokSaatIni + 1;
      // Update stok di dokumen 'materials'
      await materialDoc.ref.update({ stok: stokBaru });
    }
  }

  // Modifikasi berhasil
  return {
    success: true,
  };
};
