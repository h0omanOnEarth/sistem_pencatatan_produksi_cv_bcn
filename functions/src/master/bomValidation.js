const admin = require("firebase-admin");
const {
    log,
    info,
    debug,
    warn,
    error,
    write,
} = require("firebase-functions/logger");

exports.bomValidation = async (req) => {
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
        return material.jumlah > 0;
    })) {
        return { success: false, message: "jumlah pada detail harus di atas 0" };
    }

    if (!materials.every(material => {
        return material.batch.trim!=="";
    })) {
        return { success: false, message: "batch tidak boleh kosong" };
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


exports.detailBOMValidation = async (req) => {
    const { material_id, bom_id, jumlah } = req.data;
    
    // Periksa apakah material_id sudah ada dalam subkoleksi detail_bill_of_materials
    const bomDetailsRef = admin
    .firestore()
    .collection("bill_of_materials")
    .doc(bom_id)
    .collection("detail_bill_of_materials");

    const snapshot = await bomDetailsRef
    .where("material_id", "==", material_id)
    .get();
   
    if (!snapshot.empty) {
     // Jika sudah ada data dengan material_id tersebut, edit jumlahnya
     const docId = snapshot.docs[0].id;
     const existingData = snapshot.docs[0].data();
     const existingJumlah = existingData.jumlah || 0; // Pastikan jumlah ada dan jika tidak, beri nilai default 0
     const newJumlah = existingJumlah + jumlah; // Tambahkan jumlah baru ke jumlah yang ada
     
     await bomDetailsRef.doc(docId).update({
         jumlah: newJumlah, // Perbarui jumlah dengan jumlah yang baru dihitung
     });

     return { add: false };

    }

    return { add: true };
    
}