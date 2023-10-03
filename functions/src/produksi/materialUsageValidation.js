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
    const { materials, materialRequestId, productionOrderId } = req.data;

     // Pemeriksaan apakah productionOrderId sama dengan production_order_id di koleksi material_requests
     const materialRequestSnapshot = await admin.firestore().collection("material_requests").doc(materialRequestId).get();
     if (materialRequestSnapshot.exists) {
         const materialRequestData = materialRequestSnapshot.data();
         if (materialRequestData.production_order_id !== productionOrderId) {
             return { success: false, message: "productionOrderId tidak sesuai dengan materialRequestId" };
         }
     } else {
         return { success: false, message: "Material Request dengan materialRequestId tidak ditemukan" };
     }

    if (!materials || materials.length === 0) {
        return { success: false, message: "minimal harus ada satu bahan/material" };
    }

    // Pemeriksaan jika setiap elemen memenuhi kriteria
    if (!materials.every(material => {
        return material.material_id.trim() !== "";
    })) {
        return { success: false, message: "material_id tidak boleh kosong" };
    }

    if (!materials.every(material => {
        return material.jumlah > 0;
    })) {
        return { success: false, message: "jumlah pada detail harus di atas 0" };
    }

    if (!materials.every(material => {
        return material.satuan.trim!=="";
    })) {
        return { success: false, message: "satuan tidak boleh kosong" };
    }

     // Modifikasi berhasil dan pengurangan stok
     return {
        success: true,
    };
}