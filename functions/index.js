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
const {pegawaiAdd} = require("./src/pegawaiModif")
exports.pegawaiAdd = onCall(pegawaiAdd);
