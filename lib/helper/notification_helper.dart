import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> hasNewNotifications(String posisi) async {
  QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('notifications').get();

  // Jakarta time is UTC+7
  DateTime today = DateTime.now().toUtc().add(const Duration(hours: 7));
  DateTime localToday = DateTime(today.year, today.month, today.day);

  return snapshot.docs.any((doc) {
    dynamic createdAt = doc['created_at'];

    // Handle both Timestamp and String types for created_at
    DateTime createdAtDateTime;
    if (createdAt is Timestamp) {
      // Convert Firestore timestamp to Jakarta time
      createdAtDateTime =
          createdAt.toDate().toUtc().add(const Duration(hours: 7));
    } else if (createdAt is String) {
      // Assuming createdAt is a date string in the format 'yyyy-MM-dd'
      createdAtDateTime =
          DateTime.parse(createdAt).toUtc().add(const Duration(hours: 7));
    } else {
      return false; // Unsupported type, consider it as not new
    }

    // Check if the 'posisi' field contains the specified value
    bool isPosisiContains = (doc['posisi'] as String).contains(posisi);

    // Check if the notification was created today in Jakarta time and 'posisi' contains the specified value
    return isPosisiContains &&
        createdAtDateTime.year == localToday.year &&
        createdAtDateTime.month == localToday.month &&
        createdAtDateTime.day == localToday.day;
  });
}
