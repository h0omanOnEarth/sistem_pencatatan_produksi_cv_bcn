const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.productionOrderValidate = async (req) => {
    const {machines, materials, jumlahProduksiEst, jumlahTenagaKerjaEst, lamaWaktuEst,
    bomId, productId
    } = req.data;

    // Pemeriksaan apakah productId sesuai dengan productId yang ada dalam koleksi 'bill_of_materials'
    const billOfMaterialsCollection = admin.firestore().collection('bill_of_materials');
    const billOfMaterialsDoc = await billOfMaterialsCollection.doc(bomId).get();

    if (!billOfMaterialsDoc.exists) {
      return {
        success: false,
        message: "bill_of_materials dengan bomId yang diberikan tidak ditemukan",
      };
    }

    const billOfMaterialsData = billOfMaterialsDoc.data();
    if (billOfMaterialsData.product_id !== productId) {
      return {
        success: false,
        message: "product_id tidak sesuai dengan product_id yang ada dalam bill_of_materials",
      };
    }

    if (!materials || materials.length === 0) {
      return {success: false, message: "minimal harus ada satu bahan/material pada detail"};
    }

    if (machines.length!=3) {
      return {success: false, message: "harus memilih mesin terlebih dahulu"};
    }
  
    // Pemeriksaan jika setiap elemen memenuhi kriteria
    if (!materials.every((material) => {
      return material.material_id.trim() !== "";
    })) {
      return {success: false, message: "material_id pada detail tidak boleh kosong"};
    }
  
    if (!materials.every((material) => {
      return material.jumlah_bom > 0;
    })) {
      return { success: false, message: "jumlah pada detail harus di atas 0" };
    }
  
    if (!materials.every((material) => {
      return material.satuan.trim!=="";
    })) {
      return { success: false, message: "satuan pada detail tidak boleh kosong" };
    }

    if (!materials.every((material) => {
      return material.batch.trim!=="";
    })) {
      return { success: false, message: "batch pada detail tidak boleh kosong" };
    }

    if (!jumlahProduksiEst || jumlahProduksiEst <= 0) {
      return {
        success: false,
        message: "jumlah produksi harus lebih besar dari 0",
      };
    }

    if (!jumlahTenagaKerjaEst || jumlahTenagaKerjaEst <= 0) {
      return {
        success: false,
        message: "jumlah tenaga kerja harus lebih besar dari 0",
      };
    }

    if (!lamaWaktuEst || lamaWaktuEst <= 0) {
      return {
        success: false,
        message: "lama waktu harus lebih besar dari 0",
      };
    }

    return {
        success: true,
      };
}