const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.invoiceValidation = async (req) => {
  const { products, totalProduk, totalHarga, shipmentId, mode } = req.data;

  if (!products || products.length === 0) {
    return { success: false, message: "Minimal harus ada satu produk" };
  }

  if (!totalProduk || isNaN(totalProduk) || totalProduk < 0) {
    return { success: false, message: "Total produk harus lebih besar dari 0" };
  }

  if (!totalHarga || isNaN(totalHarga) || totalHarga < 0) {
    return { success: false, message: "Total harga harus lebih besar dari 0" };
  }

  try {
    // Periksa status_shp pada shipmentId
    const shipmentsRef = admin
      .firestore()
      .collection("shipments")
      .doc(shipmentId);

    const shipmentDoc = await shipmentsRef.get();

    if (!shipmentDoc.exists) {
      return {
        success: false,
        message: "Surat jalan tidak ditemukan",
      };
    }

    const statusShp = shipmentDoc.data().status_shp;

    if (mode == "add") {
      if (statusShp === "Selesai") {
        return {
          success: false,
          message: "Surat jalan telah dibuat",
        };
      }
    }

    // Update status_shp to "Selesai" in the shipment document
    await shipmentsRef.update({ status_shp: "Selesai" });

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating invoice:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi invoice",
    };
  }
};
