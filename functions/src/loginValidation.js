const admin = require("firebase-admin");
const {
  log,
  info,
  debug,
  warn,
  error,
  write,
} = require("firebase-functions/logger");

exports.loginValidation = async (req) => {
  try {
    const {email, password} = req.data;

    // Periksa apakah email ada di Firestore
    const employeesColl = await admin.firestore().collection("employees");
    const qSnap = await employeesColl.where("email", "==", email).get();
    log(qSnap);
    if (qSnap.empty) {
      return {success:false,message: "Email not found"};
    }

    // Ambil dokumen pertama yang cocok dengan email
    const userDoc = qSnap.docs[0];
    const userData = userDoc.data();

    // Bandingkan kata sandi yang diberikan dengan kata sandi yang tersimpan
    if (userData.password !== password) {
      return {
        success:false,
        message: "Incorect password"
      };
    }

    // Login berhasil
    return {
      success: true,
      user: {
        email: userData['email'],
        password: userData['passsword'],
        posisi: userData['posisi']
      }
    }
  } catch (error) {
    return {
      success: false,
      message: error.message
    };
  }

}