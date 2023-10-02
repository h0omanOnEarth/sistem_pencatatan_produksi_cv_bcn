/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const admin = require('firebase-admin');
const {onRequest,onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

//validasi login
const {loginValidation} = require("./src/loginValidation")
exports.loginValidation = onCall(loginValidation);

//validasi pegawai
const {pegawaiAdd} = require("./src/master/pegawaiModif")
exports.pegawaiAdd = onCall(pegawaiAdd);

const {pegawaiUpdate} = require("./src/master/pegawaiModif")
exports.pegawaiUpdate = onCall(pegawaiUpdate);

//validasi supplier
const {supplierAdd} = require("./src/master/supplierModif")
exports.supplierAdd = onCall(supplierAdd);

//validasi bahan
const {materialModif} = require("./src/master/bahanValidation")
exports.materialModif = onCall(materialModif);

//validasi barang
const {productValidation} = require("./src/master/barangValidation")
exports.productValidation = onCall(productValidation);

//validasi mesin
const {mesinValidation} = require("./src/master/mesinValidation")
exports.mesinValidation = onCall(mesinValidation);

//validasi bom
const {bomValidation} = require("./src/master/bomValidation")
exports.bomValidation = onCall(bomValidation);

const {detailBOMValidation} = require("./src/master/bomValidation")
exports.detailBOMValidation = onCall(detailBOMValidation);

//validasi purchase order
const {purchaseOrderValidation} = require("./src/pembelian/pembelianValidation")
exports.purchaseOrderValidation = onCall(purchaseOrderValidation);

//validasi purchase return
const {purchaseReturnValidation} = require("./src/pembelian/pengembalianPesananValidation")
exports.purchaseReturnValidation = onCall(purchaseReturnValidation);

//customer order
const {customerOrderValidation} = require("./src/penjualan/pesananPelangganValidation")
exports.customerOrderValidation = onCall(customerOrderValidation);