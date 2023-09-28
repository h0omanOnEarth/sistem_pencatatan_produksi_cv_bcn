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
        return { success: false, message: "Email telah digunakan" };
    }

    // Check if the username is already taken
    const qSnapUname = await employeesColl.where("username", "==", username).get();
    if (!qSnapUname.empty) {
        return { success: false, message: "Username telah digunakan" };
    }

    // Check if the password meets the minimum length requirement (8 characters)
    if (password.length < 8) {
        return { success: false, message: "Panjang password minimal 8" };
    }
    
    // Check if telp contains only numeric characters
    if (!/^\d+$/.test(telp)) {
        return { success: false, message: "Nomor telepon hanya bisa angka" };
    }

    // Check if gajiHarian is provided, numeric, and not less than 0
    if (!gajiHarian || isNaN(gajiHarian) || gajiHarian < 0) {
        return { success: false, message: "Gaji harus lebih besar dari 0" };
    }

    // Check if gajiLembur is provided, numeric, and not less than 0
    if (!gajiLembur || isNaN(gajiLembur) || gajiLembur < 0) {
        return { success: false, message: "Gaji lembur harus lebih besar dari 0" };
    }

    // Check if status is provided and numeric
    if (!status || isNaN(status)) {
        return { success: false, message: "Status harus angka" };
    }

     // Modifikasi berhasil
     return {
        success: true,
    }
  }

  exports.pegawaiUpdate  = async (req)=> {
    const {username, telp, gajiHarian, gajiLembur, status, currentUser} = req.data;

    const employeesColl = await admin.firestore().collection("employees");
    const currentUsername = currentUser;
    // Check if the username is already taken by other users (kecuali pengguna saat ini)
    const qSnapUname = await employeesColl.where("username", "==", username).get();
    if (!qSnapUname.empty) {
        // Check if the username is already taken by someone other than the current user
        const existingUsers = qSnapUname.docs.filter(doc => doc.data().username === username);
        if (existingUsers.length > 1 && existingUsers[0].data().username!=currentUsername){
            return { success: false, message: "Username telah digunakan" };
        }
    }

      // Check if telp contains only numeric characters
        if (!/^\d+$/.test(telp)) {
        return { success: false, message: "Nomor telepon hanya bisa angka" };
    }

    // Check if gajiHarian is provided, numeric, and not less than 0
    if (!gajiHarian || isNaN(gajiHarian) || gajiHarian < 0) {
        return { success: false, message: "Gaji harus lebih besar dari 0" };
    }

    // Check if gajiLembur is provided, numeric, and not less than 0
    if (!gajiLembur || isNaN(gajiLembur) || gajiLembur < 0) {
        return { success: false, message: "Gaji lembur harus lebih besar dari 0" };
    }

    // Check if status is provided and numeric
    if (!status || isNaN(status)) {
        return { success: false, message: "Status harus angka" };
    }

     // Modifikasi berhasil
     return {
        success: true,
    }
  }

