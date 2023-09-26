import 'package:sistem_manajemen_produksi_cv_bcn/models/detail_notification.dart';

class Notification {
  final String id;
  final String pesan;
  final int status;
  final DateTime createdAt;
  final List<DetailNotification> detailNotifications;

  Notification({
    required this.id,
    required this.pesan,
    required this.status,
    required this.createdAt,
    this.detailNotifications = const [],
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailJsonList = json['detail_notifications'] ?? [];
    final List<DetailNotification> detailNotifications = detailJsonList
        .map((detailJson) => DetailNotification.fromJson(detailJson))
        .toList();

    return Notification(
      id: json['id'] as String,
      pesan: json['pesan'] as String,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      detailNotifications: detailNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailNotificationsJson =
        detailNotifications.map((detail) => detail.toJson()).toList();

    return {
      'id': id,
      'pesan': pesan,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'detail_notifications': detailNotificationsJson,
    };
  }
}
