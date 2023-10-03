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
    const { materials } = req.data;

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
        return material.jumlah_bom > 0;
    })) {
        return { success: false, message: "jumlah pada detail harus di atas 0" };
    }

    if (!materials.every(material => {
        return material.satuan.trim!=="";
    })) {
        return { success: false, message: "satuan tidak boleh kosong" };
    }

     // Modifikasi berhasil
     return {
        success: true,
    };
}