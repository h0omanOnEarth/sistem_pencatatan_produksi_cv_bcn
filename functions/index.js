/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const admin = require("firebase-admin");
const { onRequest, onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { setGlobalOptions, https } = require("firebase-functions/v2");
const nodemailer = require("nodemailer");
const cors = require("cors");

setGlobalOptions({ region: "asia-southeast2" });

admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const { sendEmailNotif } = require("./src/sendMail");
exports.sendEmailNotif = https.onCall({ cors: true }, sendEmailNotif);

// validasi login
const { loginValidation } = require("./src/loginValidation");
exports.loginValidation = onCall(loginValidation);

// validasi pegawai
const { pegawaiAdd } = require("./src/master/pegawai");
exports.pegawaiAdd = onCall(pegawaiAdd);

const { pegawaiUpdate } = require("./src/master/pegawai");
exports.pegawaiUpdate = onCall(pegawaiUpdate);

// validasi supplier
const { supplierAdd } = require("./src/master/supplier");
exports.supplierAdd = onCall(supplierAdd);

// validasi bahan
const { materialModif } = require("./src/master/bahan");
exports.materialModif = onCall(materialModif);

// validasi barang
const { productValidation } = require("./src/master/barang");
exports.productValidation = onCall(productValidation);

// validasi mesin
const { mesinValidation } = require("./src/master/mesin");
exports.mesinValidation = onCall(mesinValidation);

// validasi bom
const { bomValidation } = require("./src/master/bom");
exports.bomValidation = onCall(bomValidation);

const { detailBOMValidation } = require("./src/master/bom");
exports.detailBOMValidation = onCall(detailBOMValidation);

// validasi purchase order
const { purchaseOrderValidation } = require("./src/pembelian/pembelian");
exports.purchaseOrderValidation = onCall(purchaseOrderValidation);

// customer order
const { customerOrderValidation } = require("./src/penjualan/pesananPelanggan");
exports.customerOrderValidation = onCall(customerOrderValidation);

// invoice
const { invoiceValidation } = require("./src/penjualan/invoice");
exports.invoiceValidation = onCall(invoiceValidation);

// material request
const { materialRequestValidation } = require("./src/produksi/materialRequest");
exports.materialRequestValidation = onCall(materialRequestValidation);

// material usage
const { materialUsageValidation } = require("./src/produksi/materialUsage");
exports.materialUsageValidation = onCall(materialUsageValidation);

// material return
const { materialReturnValidation } = require("./src/produksi/materialReturn");
exports.materialReturnValidation = onCall(materialReturnValidation);

// dloh
const { dlohValidation } = require("./src/produksi/dloh");
exports.dlohValidation = onCall(dlohValidation);

// production result
const { productionResValidate } = require("./src/produksi/productionResult");
exports.productionResValidate = onCall(productionResValidate);

//production confirmation
const {
  productionConfirmationValidation,
} = require("./src/produksi/productionConfirmation");
exports.productionConfirmationValidation = onCall(
  productionConfirmationValidation
);

//production order
const { productionOrderValidate } = require("./src/produksi/productionOrder");
exports.productionOrderValidate = onCall(productionOrderValidate);

//purchase request
const { purchaseReqValidation } = require("./src/pembelian/purchaseRequest");
exports.purchaseReqValidation = onCall(purchaseReqValidation);

//material receive
const { materialRecValidation } = require("./src/pembelian/materialReceive");
exports.materialRecValidation = onCall(materialRecValidation);

//material transfer
const {
  materialTransferValidation,
} = require("./src/produksi/materialTransfer");
exports.materialTransferValidation = onCall(materialTransferValidation);

//item receive
const { itemReceiveValidation } = require("./src/produksi/itemReceive");
exports.itemReceiveValidation = onCall(itemReceiveValidation);

//material transform
const {
  materialTransformValidate,
} = require("./src/produksi/materialTransform");
exports.materialTransformValidate = onCall(materialTransformValidate);

//surat jalan
const { suratJalanValidation } = require("./src/penjualan/suratJalan");
exports.suratJalanValidation = onCall(suratJalanValidation);

//customer order return
const {
  customerOrderReturnValidation,
} = require("./src/penjualan/customerOrderReturn");
exports.customerOrderReturnValidation = onCall(customerOrderReturnValidation);

//purchase return
const {
  purchaseReturnValidation,
} = require("./src/pembelian/pengembalianPesanan");
exports.purchaseReturnValidation = onCall(purchaseReturnValidation);

//delivery order
const { deliveryOrderValidate } = require("./src/penjualan/deliveryOrder");
exports.deliveryOrderValidate = onCall(deliveryOrderValidate);
