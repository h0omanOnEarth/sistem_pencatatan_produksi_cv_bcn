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
}
