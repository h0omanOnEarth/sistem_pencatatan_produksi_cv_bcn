import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> generateNextNotificationId() async {
    final QuerySnapshot snapshot = await firestore.collection('notifications').get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc.id).toList();
    int notificationCount = 1;

    while (true) {
      final nextNotificationId = 'NOTIF${notificationCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextNotificationId)) {
        return nextNotificationId;
      }
      notificationCount++;
    }
  }

  Future<void> addNotification(String pesan, String posisi) async {
  try {
    final notificationsRef = firestore.collection('notifications');
    final nextNotifId = await generateNextNotificationId();
    final Map<String, dynamic> notificationData = {
      'pesan': pesan,
      'status': 1,
      'posisi': posisi,
      'created_at' : DateTime.now(),
      'id': nextNotifId
    };

    // Gunakan .doc() untuk membuat referensi dokumen baru dengan nextNotifId
    final newNotificationDoc = notificationsRef.doc(nextNotifId);

    // Gunakan .set() untuk menambahkan data ke dokumen tersebut
    await newNotificationDoc.set(notificationData);
  } catch (error) {
    print('Error adding notification: $error');
    // Handle error here, e.g., show an error message to the user
  }
}

}
