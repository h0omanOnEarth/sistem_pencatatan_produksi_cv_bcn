const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.purchaseReturnValidation = async (req) => {
  const {jumlah, purchaseOrderId, satuan, qtyLama, mode} = req.data;

  try {
    // Periksa apakah purchase order memiliki status_pengiriman "Selesai"
    const purchaseOrderRef = admin.firestore().collection("purchase_orders").where("id", "==", purchaseOrderId);
    const purchaseOrderQuery = await purchaseOrderRef.get();

    if (purchaseOrderQuery.empty) {
      return { success: false, message: "purchase order tidak ditemukan" };
    }

    const purchaseOrderDoc = purchaseOrderQuery.docs[0];
    const purchaseOrderData = purchaseOrderDoc.data();

    if (purchaseOrderData.status_pengiriman !== "Selesai") {
      return { success: false, message: "status pengiriman pada purchase order belum 'Selesai'" };
    }

    if (purchaseOrderData.satuan != satuan) {
      return { success: false, message: `satuan seharusnya ${purchaseOrderData.satuan}` };
    }

    // Periksa apakah jumlah tidak melebihi jumlah pada purchase order
    if (jumlah > purchaseOrderData.jumlah) {
      return { success: false, message: "jumlah pengembalian melebihi jumlah pada purchase order" };
    }

    // Kurangi stok pada koleksi 'materials'
    const materialId = purchaseOrderData.material_id;
    const materialRef = admin.firestore().collection("materials").where("id", "==", materialId);
    const materialQuery = await materialRef.get();

    if (!materialQuery.empty) {
      const materialDoc = materialQuery.docs[0];
      const materialData = materialDoc.data();
      const stokSaatIni = materialData.stok || 0; // Jika tidak ada stok sebelumnya, gunakan 0

      let stokBaru = 0;
      
      if(mode=='add'){
        stokBaru = stokSaatIni - jumlah;
      }else{
        stokBaru = stokSaatIni + qtyLama - jumlah;
      }

      // Pastikan stok tidak menjadi negatif
      if (stokBaru < 0) {
        return { success: false, message: "stok material tidak cukup untuk pengembalian ini" };
      }

      // Update stok di dokumen 'materials'
      await materialDoc.ref.update({ stok: stokBaru });
    } else {
      // Materi tidak ditemukan, lakukan penanganan kesalahan di sini jika diperlukan
      return { success: false, message: "Material tidak ditemukan" };
    }

    return { success: true };
  } catch (error) {
    console.error("Error validating purchase return:", error);
    return { success: false, message: "Terjadi kesalahan dalam validasi pengembalian pembelian" };
  }
};
