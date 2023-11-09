const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.productionResValidate = async (req) => {
  const {
    total,
    jumlahBerhasil,
    jumlahCacat,
    waktu,
    materialUsageId,
    satuan,
    mode,
  } = req.data;

  if (!total || total <= 0) {
    return {
      success: false,
      message: "Total hasil produksi harus lebih besar dari 0",
    };
  }

  if (!jumlahBerhasil || jumlahBerhasil <= 0) {
    return {
      success: false,
      message: "Jumlah berhasil harus lebih besar dari 0",
    };
  }

  if (!jumlahCacat || jumlahCacat <= 0) {
    return {
      success: false,
      message: "Jumlah cacat harus lebih besar dari 0",
    };
  }

  if (!waktu || waktu <= 0) {
    return {
      success: false,
      message: "Waktu produksi harus lebih besar dari 0",
    };
  }

  try {
    // Dapatkan material usage yang sesuai dengan materialUsageId
    const materialUsageRef = admin
      .firestore()
      .collection("material_usages")
      .doc(materialUsageId);
    const materialUsageDoc = await materialUsageRef.get();

    // Periksa status_mu pada materialUsage
    const statusMu = materialUsageDoc.data().status_mu;

    if (statusMu !== "Selesai") {
      return {
        success: false,
        message: `Material usage belum 'Selesai', status saat ini: ${statusMu}`,
      };
    }

    // Periksa batch pada materialUsage
    const batch = materialUsageDoc.data().batch;

    if (batch !== "Pencetakan") {
      return {
        success: false,
        message: "Batch harus 'Pencetakan'",
      };
    }

    // Periksa apakah production_results sudah ada untuk materialUsageId
    const productionResultsQuery = await admin
      .firestore()
      .collection("production_results")
      .where("material_usage_id", "==", materialUsageId)
      .get();

    if (mode == "add") {
      if (!productionResultsQuery.empty) {
        return {
          success: false,
          message:
            "Sudah ada pencatatan hasil produksi untuk nomor penggunaan bahan ini",
        };
      }
    }

    // Periksa status produksi pada materialUsage
    const productionOrderId = materialUsageDoc.data().production_order_id;
    const productionOrderRef = admin
      .firestore()
      .collection("production_orders")
      .doc(productionOrderId);
    const productionOrderDoc = await productionOrderRef.get();
    const productionOrderStatus = productionOrderDoc.data().status_pro;

    if (mode == "add") {
      if (productionOrderStatus === "Selesai") {
        return {
          success: false,
          message:
            "Status perintah produksi dalam nomor penggunana bahan ini sudah 'Selesai'",
        };
      }
    }

    // Dapatkan product_id dari production_order
    const productId = productionOrderDoc.data().product_id;

    // Tambahkan stok pada koleksi products
    const productsRef = admin.firestore().collection("products");
    const productQuerySnapshot = await productsRef
      .where("id", "==", productId)
      .get();

    if (!productQuerySnapshot.empty) {
      const productDocRef = productQuerySnapshot.docs[0].ref;
      const currentStock = (await productDocRef.get()).data().stok;
      const productSatuan = (await productDocRef.get()).data().satuan;

      // Periksa apakah satuan sama dengan produk
      if (satuan !== productSatuan) {
        return {
          success: false,
          message: `Satuan ${satuan} tidak cocok dengan satuan produk (${productSatuan})`,
        };
      }

      // Perbarui stok produk gagal
      // // Perbarui stok produk
      // await productDocRef.update({stok: currentStock + total});
      // Perbarui stok produk cacat
      // Dapatkan stok produk dengan id 'productXXX'
      const productXXXRef = productsRef.doc("productXXX");
      const productXXXDoc = await productXXXRef.get();
      const stokProductXXX = productXXXDoc.data().stok;
      // Perbarui stok produk gagal
      await productXXXRef.update({ stok: stokProductXXX + jumlahCacat });
    }

    // Jika semua pemeriksaan berhasil, ubah status produksi menjadi 'Selesai'
    await productionOrderRef.update({ status_pro: "Selesai" });

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error validating production result:", error);
    return {
      success: false,
      message: "Terjadi kesalahan dalam validasi hasil produksi",
    };
  }
};
