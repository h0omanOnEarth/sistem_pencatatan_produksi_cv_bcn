const admin = require("firebase-admin");
const {
    log,
    info,
    debug,
    warn,
    error,
    write,
  } = require("firebase-functions/logger");

  exports.pegawaiAdd = async (req)=> {
    const {username, email, password, telp, gajiHarian, gajiLembur, status} = req.data;

    const employeesColl = await admin.firestore().collection("employees");
    // Check if the email is already taken
    const qSnapEmail = await employeesColl.where("email", "==", email).get();
    if (!qSnapEmail.empty) {
        return { success: false, message: "Email has been taken" };
    }

    // Check if the username is already taken
    const qSnapUname = await employeesColl.where("username", "==", username).get();
    if (!qSnapUname.empty) {
        return { success: false, message: "Username has been taken" };
    }

    // Check if the password meets the minimum length requirement (8 characters)
    if (password.length < 8) {
        return { success: false, message: "Password must be at least 8 characters long" };
    }
    
    // Check if telp contains only numeric characters
    if (!/^\d+$/.test(telp)) {
        return { success: false, message: "Phone number must contain only numeric characters" };
    }

    // Check if gajiHarian is provided, numeric, and not less than 0
    if (!gajiHarian || isNaN(gajiHarian) || gajiHarian < 0) {
        return { success: false, message: "Gaji Harian must be a non-negative number" };
    }

    // Check if gajiLembur is provided, numeric, and not less than 0
    if (!gajiLembur || isNaN(gajiLembur) || gajiLembur < 0) {
        return { success: false, message: "Gaji Lembur must be a non-negative number" };
    }

    // Check if status is provided and numeric
    if (!status || isNaN(status)) {
        return { success: false, message: "Status must be a number" };
    }

     // Login berhasil
     return {
        success: true,
    }
    
  }