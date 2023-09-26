class NotificationModel {
  final DateTime createdAt;
  final String id;
  final String pesan;
  final String posisi;
  final int status;

  NotificationModel({
    required this.createdAt,
    required this.id,
    required this.pesan,
    required this.posisi,
    required this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
      pesan: json['pesan'],
      posisi: json['posisi'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toUtc(), // Mengonversi ke UTC DateTime
      'id': id,
      'pesan': pesan,
      'posisi': posisi,
      'status': status,
    };
  }
}
