const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.productionConfirmationValidation = async (req) => {
  const { confirmations } = req.data;

  if (!confirmations || confirmations.length === 0) {
    return {
      success: false,
      message: "Detail konfirmasi harus ada satu hasil produksi",
    };
  }

  if (
    !confirmations.every((confirmation) => {
      return confirmation.production_result_id.trim() !== "";
    })
  ) {
    return {
      success: false,
      message: "Nomor hasil produksi pada detail\n tidak boleh kosong",
    };
  }

  if (
    !confirmations.every((confirmation) => {
      return confirmation.jumlah_konfirmasi > 0;
    })
  ) {
    return {
      success: false,
      message: "Jumlah konfirmasi pada detail harus di atas 0",
    };
  }

  if (
    !confirmations.every((confirmation) => {
      return confirmation.satuan.trim !== "";
    })
  ) {
    return { success: false, message: "Satuan pada detail tidak boleh kosong" };
  }

  // Mengambil koleksi 'production_results' dari Firestore
  const productionResultsCollection = admin
    .firestore()
    .collection("production_results");

  // Membuat daftar id produksi yang diperlukan untuk pencocokan
  const productionResultIds = confirmations.map((confirmation) =>
    confirmation.production_result_id.trim(),
  );

  try {
    // Mendapatkan data produksi yang sesuai berdasarkan production_result_id
    const productionResultsData = await productionResultsCollection
      .where("id", "in", productionResultIds)
      .get();
    // Memeriksa apakah jumlah_konfirmasi tidak melebihi jumlah_produk dari produksi yang sesuai
    if (!productionResultsData.empty) {
      const valid = confirmations.every((confirmation) => {
        const productionResult = productionResultsData.docs.find(
          (doc) => doc.id === confirmation.production_result_id.trim(),
        );
        const jumlahProduk = productionResult.data().jumlah_produk_berhasil;
        return confirmation.jumlah_konfirmasi <= jumlahProduk;
      });

      if (!valid) {
        return {
          success: false,
          message:
            "Jumlah konfirmasi melebihi jumlah produk berhasil pada hasil produksi",
        };
      }

      // Jika semua konfirmasi valid, ubah status_prs menjadi 'Selesai'
      const batch = admin.firestore().batch();
      productionResultsData.docs.forEach((doc) => {
        const productionResultRef = productionResultsCollection.doc(doc.id);
        batch.update(productionResultRef, { status_prs: "Selesai" });
      });

      await batch.commit();
    }
    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating production confirmation:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi konfirmasi produksi",
    };
  }
};
