const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.purchaseReturnValidation = async (req) => {

  return {
    success: true,
  };
};
