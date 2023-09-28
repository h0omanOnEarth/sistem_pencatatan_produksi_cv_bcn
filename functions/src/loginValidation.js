const admin = require('firebase-admin');
admin.initializeApp();

exports.validateLogin = functions.https.onCall(async (data, context) => {
  try {
    const { email, password } = data;

    // Periksa apakah email ada di Firestore
    const employeesCollection = admin.firestore().collection('employees');
    const querySnapshot = await employeesCollection.where('email', '==', email).get();

    if (querySnapshot.empty) {
      return { error: 'Email not found' };
    }

    // Ambil dokumen pertama yang cocok dengan email
    const userDoc = querySnapshot.docs[0];
    const userData = userDoc.data();

    // Bandingkan kata sandi yang diberikan dengan kata sandi yang tersimpan
    if (userData.password !== password) {
      return { error: 'Incorrect password' };
    }

    // Login berhasil
    return { success: true, user: userData };
  } catch (error) {
    return { error: error.message };
  }
});
