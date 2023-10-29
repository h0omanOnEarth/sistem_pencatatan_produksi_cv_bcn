const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialTransferValidation = async (req) => {
  const { materials, materialRequestId } = req.data;

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

  try {
    // Periksa status material request (status_mr)
    const materialRequestRef = admin
      .firestore()
      .collection("material_requests")
      .doc(materialRequestId);
    const materialRequestDoc = await materialRequestRef.get();

    if (!materialRequestDoc.exists) {
      return { success: false, message: "Material request tidak ditemukan" };
    }

    const materialRequestData = materialRequestDoc.data();

    if (materialRequestData.status_mr === "Selesai") {
      return { success: false, message: "Material request sudah 'Selesai'" };
    }

    // Pemeriksaan stok material
    for (const material of materials) {
      const materialId = material.material_id;
      const jumlah = material.jumlah;

      const materialRef = admin
        .firestore()
        .collection("materials")
        .where("id", "==", materialId);
      const materialQuery = await materialRef.get();

      if (!materialQuery.empty) {
        const materialDoc = materialQuery.docs[0];
        const materialData = materialDoc.data();
        const stokSaatIni = materialData.stok || 0; // Jika tidak ada stok sebelumnya, gunakan 0

        if (stokSaatIni - jumlah < 0) {
          return {
            success: false,
            message: `Stok material '${materialId}' tidak mencukupi`,
          };
        }
      } else {
        return {
          success: false,
          message: `Material '${materialId}' tidak ditemukan`,
        };
      }
    }

    // Mengurangi stok material
    for (const material of materials) {
      const materialId = material.material_id;
      const jumlah = material.jumlah;

      const materialRef = admin
        .firestore()
        .collection("materials")
        .where("id", "==", materialId);
      const materialQuery = await materialRef.get();

      if (!materialQuery.empty) {
        const materialDoc = materialQuery.docs[0];
        const materialData = materialDoc.data();
        const stokSaatIni = materialData.stok || 0;

        const stokBaru = stokSaatIni - jumlah;

        // Pastikan stok tidak menjadi negatif
        if (stokBaru < 0) {
          return {
            success: false,
            message: `Stok material '${materialId}' tidak mencukupi`,
          };
        }

        // Update stok di dokumen 'materials'
        await materialDoc.ref.update({ stok: stokBaru });
      }
    }

    // Ubah status_mr menjadi "Selesai"
    await materialRequestRef.update({ status_mr: "Selesai" });

    return { success: true };
  } catch (error) {
    console.error("Error validating material transfer:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi material transfer",
    };
  }
};
