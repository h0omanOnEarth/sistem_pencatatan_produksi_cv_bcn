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
  const { materials, materialUsageId, mode} = req.data;

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

  try {
    // Dapatkan jumlah material yang sudah digunakan dari subkoleksi detail_material_usages pada material_usages
    const materialUsageRef = admin.firestore().collection("material_usages").doc(materialUsageId);

    const materialUsageDoc = await materialUsageRef.get();

    // Periksa status_mu pada materialUsageId
    const statusMu = materialUsageDoc.data().status_mu;

    if(mode=='add'){
      if (statusMu !== "Selesai") {
        return {
          success: false,
          message: `Status materialUsageId bukan 'Selesai', status saat ini: ${statusMu}`,
        };
      }
    }

    const detailMaterialUsageQuery = await materialUsageRef.collection("detail_material_usages").get();
    let materialUsageQuantities = {};
    let materialUsageUnits = {};

    detailMaterialUsageQuery.forEach((doc) => {
      const detailMaterialUsageData = doc.data();
      const materialId = detailMaterialUsageData.material_id;
      const quantity = detailMaterialUsageData.jumlah;
      const unit = detailMaterialUsageData.satuan;

      if (!materialUsageQuantities[materialId]) {
        materialUsageQuantities[materialId] = 0;
      }

      materialUsageQuantities[materialId] += quantity;
      materialUsageUnits[materialId] = unit;
    });

    // Periksa jumlah material dalam materials
    for (const material of materials) {
      const materialId = material.material_id;
      const quantityInMaterials = material.jumlah;
      const quantityInMaterialUsage = materialUsageQuantities[materialId];
      const unitInMaterials = material.satuan;
      const unitInMaterialUsage = materialUsageUnits[materialId];

      if (quantityInMaterials > quantityInMaterialUsage) {
        return {
          success: false,
          message: `Jumlah ${materialId} melebihi yang digunakan dalam material usage, yang digunakan ${quantityInMaterialUsage}`,
        };
      }

      if (unitInMaterials !== unitInMaterialUsage) {
        return {
          success: false,
          message: `Satuan ${materialId} tidak cocok dengan yang digunakan dalam material usage, yang digunakan ${unitInMaterialUsage}`,
        };
      }
    }

    // Jika validasi berhasil, tambahkan stok pada 'materials' sesuai dengan material_id
    const materialsRef = admin.firestore().collection("materials");
    const batch = admin.firestore().batch();

    for (const material of materials) {
      const materialId = material.material_id;
      const quantityInMaterials = material.jumlah;

      // Mencari dokumen dengan id yang cocok dengan materialId
      const materialQuerySnapshot = await materialsRef.where("id", "==", materialId).get();

      if (!materialQuerySnapshot.empty) {
        const materialDocRef = materialQuerySnapshot.docs[0].ref;
        const currentStock = (await materialDocRef.get()).data().stok;

        // Perbarui stok material
        batch.update(materialDocRef, { stok: currentStock + quantityInMaterials });
      }
    }

    // Simpan perubahan stok dalam satu transaksi batch
    await batch.commit();

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating material return:", error);
    return { success: false, message: "Terjadi kesalahan dalam validasi material return" };
  }
};
