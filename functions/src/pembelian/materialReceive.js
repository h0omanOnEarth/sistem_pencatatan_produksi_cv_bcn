const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialRecValidation = async (req) => {
  const {
    jumlahPermintaan,
    jumlahDiterima,
    materialId,
    purchaseReqId,
    supplierId,
    mode,
    stokLama,
  } = req.data;

  if (!jumlahPermintaan || isNaN(jumlahPermintaan) || jumlahPermintaan < 0) {
    return {
      success: false,
      message: "Jumlah permintaan harus lebih besar dari 0",
    };
  }

  if (!jumlahDiterima || isNaN(jumlahDiterima) || jumlahDiterima < 0) {
    return {
      success: false,
      message: "Jumlah diterima harus lebih besar dari 0",
    };
  }

  try {
    // Periksa apakah purchase request memiliki status "Selesai" pada koleksi 'purchase_requests'
    const purchaseRequestRef = admin
      .firestore()
      .collection("purchase_requests")
      .doc(purchaseReqId);
    const purchaseRequestDoc = await purchaseRequestRef.get();

    if (!purchaseRequestDoc.exists) {
      return {
        success: false,
        message: "Permintaan pembelian tidak ditemukan",
      };
    }

    const purchaseRequestData = purchaseRequestDoc.data();

    if (purchaseRequestData.status_prq !== "Selesai") {
      return {
        success: false,
        message: "Permintaan pembelian masih dalam proses",
      };
    }

    // Periksa apakah materialId sama dengan yang ada di purchase_requests
    if (purchaseRequestData.material_id !== materialId) {
      return {
        success: false,
        message: `Material id tidak sesuai dengan yang ada pada purchase request,\nmaterial seharusnya ${purchaseRequestData.material_id}`,
      };
    }

    if (mode == "add") {
      // Periksa apakah purchase request sudah ada di koleksi 'material_receives'
      const materialReceiveQuery = await admin
        .firestore()
        .collection("material_receives")
        .where("purchase_request_id", "==", purchaseReqId)
        .get();

      if (!materialReceiveQuery.empty) {
        return { success: false, message: "Nomor permintaan telah diterima" };
      }
    }

    // Cari dokumen 'purchase_orders' yang memiliki 'purchase_request_id' yang sama dengan 'purchaseReqId'
    const purchaseOrderQuery = await admin
      .firestore()
      .collection("purchase_orders")
      .where("purchase_request_id", "==", purchaseReqId)
      .where("status", "==", 1)
      .get();

    if (!purchaseOrderQuery.empty) {
      const purchaseOrderDoc = purchaseOrderQuery.docs[0];
      const purchaseOrderData = purchaseOrderDoc.data();

      // Periksa apakah supplierId sama dengan supplier_id pada purchase_orders
      if (purchaseOrderData.supplier_id !== supplierId) {
        return {
          success: false,
          message: `Supplier id tidak sesuai purchase order, supplier id seharusnya ${purchaseOrderData.supplier_id}`,
        };
      }
      await purchaseOrderDoc.ref.update({ status: "Selesai" });
    } else {
      // Purchase Order tidak ditemukan, lakukan penanganan kesalahan di sini jika diperlukan
      return { success: false, message: "Purchase order tidak ditemukan" };
    }

    // Validasi berhasil
    // Cari dokumen 'materials' dengan 'id' yang sama dengan materialId
    const materialQuery = await admin
      .firestore()
      .collection("materials")
      .where("id", "==", materialId)
      .get();

    if (!materialQuery.empty) {
      const materialDoc = materialQuery.docs[0];
      const materialData = materialDoc.data();
      const stokSaatIni = materialData.stok || 0; // Jika tidak ada stok sebelumnya, gunakan 0

      let stokBaru = 0;

      if (mode == "add") {
        stokBaru = stokSaatIni + jumlahDiterima;
      } else if (mode == "edit") {
        stokBaru = stokSaatIni - stokLama + jumlahDiterima;
      }

      // Update stok di dokumen 'materials'
      await materialDoc.ref.update({ stok: stokBaru });
    } else {
      // Materi tidak ditemukan, lakukan penanganan kesalahan di sini jika diperlukan
      return { success: false, message: "Material tidak ditemukan" };
    }

    return { success: true };
  } catch (error) {
    console.error("Error validating material receive:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi material receive",
    };
  }
};
