const admin = require("firebase-admin");
const {
    log,
    info,
    debug,
    warn,
    error,
    write,
} = require("firebase-functions/logger");

exports.supplierAdd = async (req) => {
    const { telp, telpKantor, email } = req.data;

    // Check if telp contains only numeric characters
    if (!/^\d+$/.test(telp)) {
        return { success: false, message: "Nomor telepon hanya bisa angka" };
    }

    // Check if telpKantor contains only numeric characters
    if (!/^\d+$/.test(telpKantor)) {
        return { success: false, message: "Nomor telepon kantor hanya bisa angka" };
    }

    // Check if email has a valid format
    if (!isValidEmail(email)) {
        return { success: false, message: "Format email salah" };
    }

    // Modifikasi berhasil
    return {
        success: true,
    };
}

// Function to validate email format
function isValidEmail(email) {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(email);
}
