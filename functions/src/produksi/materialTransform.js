const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.materialTransformValidate = async (req) => {
    const {jumlahBarangGagal, jumlahHasil, totalHasil} = req.data;

    if (!jumlahBarangGagal || isNaN(jumlahBarangGagal) || jumlahBarangGagal < 0) {
        return {success: false, message: "Jumlah barang gagal harus lebih besar dari 0"};
    }

    if (!jumlahHasil || isNaN(jumlahHasil) || jumlahHasil < 0) {
        return {success: false, message: "Jumlah berhasil harus lebih besar dari 0"};
    }

    if (!totalHasil || isNaN(totalHasil) || totalHasil < 0) {
        return {success: false, message: "Total harus lebih besar dari 0"};
    }

    try {
        const productsRef = admin.firestore().collection("products");
        
        // Periksa stok produk 'productXXX'
        const productXXXRef = productsRef.doc('productXXX');
        const productXXXDoc = await productXXXRef.get();
        const stokProductXXX = productXXXDoc.data().stok;
        
        if (stokProductXXX - jumlahBarangGagal < 0) {
            return {success: false, message: `Stok produk gagal tidak mencukupi, stok saat ini\n ${stokProductXXX}`};
        }
        
        // Tambahkan stok pada koleksi 'materials' dengan doc ID 'materialXXX' dengan jumlahHasil
        const materialsRef = admin.firestore().collection("materials");
        const materialXXXRef = materialsRef.doc('materialXXX');
        const materialXXXDoc = await materialXXXRef.get();
        const stokMaterialXXX = materialXXXDoc.data().stok;

        // Perbarui stok produk gagal
        await materialXXXRef.update({stok: stokMaterialXXX + jumlahHasil});
        
        // Kurangi stok pada koleksi 'products' dengan doc ID 'productXXX' dengan jumlahBarangGagal
        await productXXXRef.update({stok: stokProductXXX - jumlahBarangGagal});
        
        return {
            success: true,
        };
    } catch (error) {
        console.error("Error validating material transformation:", error);
        return {success: false, message: "Terjadi kesalahan dalam validasi transformasi material"};
    }
}