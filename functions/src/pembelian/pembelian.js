const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.purchaseOrderValidation = async (req) => {
  const { hargaSatuan, jumlah, total, materialId, purchaseRequestId, mode, oldPurchaseRequestId } = req.data;

  // Check if hargaSatuan, jumlah, and total are provided, numeric, and not less than 0
  if (!hargaSatuan || isNaN(hargaSatuan) || hargaSatuan < 0) {
    return { success: false, message: "harga satuan harus lebih besar dari 0" };
  }

  if (!jumlah || isNaN(jumlah) || jumlah < 0) {
    return { success: false, message: "jumlah satuan harus lebih besar dari 0" };
  }

  if (!total || isNaN(total) || total < 0) {
    return { success: false, message: "total satuan harus lebih besar dari 0" };
  }

  try {
    // Retrieve the purchase request document from Firestore
    const purchaseRequestRef = admin.firestore().collection("purchase_requests").doc(purchaseRequestId);
    const purchaseRequestDoc = await purchaseRequestRef.get();

    // Check if the purchase request exists
    if (!purchaseRequestDoc.exists) {
      return { success: false, message: "purchase request tidak ditemukan" };
    }

    // Check if materialId matches the material_id in the purchase request document
    const purchaseRequestData = purchaseRequestDoc.data();
    if (purchaseRequestData.material_id !== materialId) {
      return { success: false, message: `material id tidak sesuai dengan purchase request id,\nmaterial id yang sesuai adalah ${purchaseRequestData.material_id}` };
    }

    // Check if the purchase request status is "Selesai" in "add" mode
    if (mode === "add" && purchaseRequestData.status_prq === "Selesai") {
      return { success: false, message: "tidak dapat membuat purchase order karena status purchase request sudah 'Selesai'" };
    }

    // Check if oldPurchaseRequestId is provided in "edit" mode
    if (mode === "edit" && oldPurchaseRequestId!=purchaseRequestId) {
      // Retrieve the old purchase request document
      const oldPurchaseRequestRef = admin.firestore().collection("purchase_requests").doc(oldPurchaseRequestId);
      const oldPurchaseRequestDoc = await oldPurchaseRequestRef.get();

      // Check if the old purchase request exists and update its status to "Dalam Proses"
      if (oldPurchaseRequestDoc.exists) {
        await oldPurchaseRequestRef.update({ status_prq: "Dalam Proses" });
      } else {
        // Handle the case where the old purchase request does not exist
        return { success: false, message: "Purchase request sebelumnya tidak ditemukan" };
      }
    }

    // Validation succeeded, update the status to "Selesai"
    await purchaseRequestRef.update({ status_prq: "Selesai" });

    // Validation succeeded
    return { success: true };
  } catch (error) {
    // Handle any errors that occurred during Firestore retrieval or updates
    console.error("Error retrieving/updating purchase request document:", error);
    return { success: false, message: "Terjadi kesalahan dalam memvalidasi purchase order" };
  }
};
