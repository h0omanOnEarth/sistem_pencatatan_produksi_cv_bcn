import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EmailNotificationService {
  static Future<void> sendNotification(
      String subject, String html, String posisi) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot employeesSnapshot = await firestore
          .collection('employees')
          .where('posisi', isEqualTo: posisi)
          .get();

      // Membuat daftar email dari hasil kueri Firestore
      final List<String> emails =
          employeesSnapshot.docs.map((doc) => doc['email'] as String).toList();

      if (emails.isEmpty) {
        print('Tidak ada email yang sesuai dengan kriteria.');
      } else {
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'asia-southeast2')
                .httpsCallable('sendEmailNotif');
        final List<Future<HttpsCallableResult>> results = [];

        // Mengirim notifikasi ke setiap email
        for (final email in emails) {
          final Future<HttpsCallableResult> result =
              callable.call(<String, dynamic>{
            'dest': email,
            'subject': subject,
            'html': html,
          });
          results.add(result);
        }

        // Menunggu semua notifikasi selesai dikirim
        await Future.wait(results);

        print('Emails Sent');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
