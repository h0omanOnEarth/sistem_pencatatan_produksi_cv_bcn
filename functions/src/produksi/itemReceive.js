const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.itemReceiveValidation = async (req) => {
    const {products, productionConfirmationId} = req.data;
    log(products);
    
    if (!products || products.length === 0) {
        return {success: false, message: "Detail harus ada satu produk"};
    }
      
    if (!products.every((product) => {
      return product.product_id.trim() !== "";
    })) {
      return {success: false, message: "Kode produk pada detail\n tidak boleh kosong"};
    }
  
    if (!products.every((product) => {
      return product.jumlah_pcs > 0;
    })) {
      return {success: false, message: "Jumlah pada detail harus di atas 0"};
    }

    return {
        success: true,
    };
}