class DetailNotification {
  final String employeeId;
  final String id;
  final String notificationId;

  DetailNotification({
    required this.employeeId,
    required this.id,
    required this.notificationId,
  });

  factory DetailNotification.fromJson(Map<String, dynamic> json) {
    return DetailNotification(
      employeeId: json['employee_id'] as String,
      id: json['id'] as String,
      notificationId: json['notification_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'id': id,
      'notification_id': notificationId,
    };
  }
}
