class MachineDetail {
  final String batch;
  final String id;
  final String machineId;
  final String productionOrderId;
  final int status;

  MachineDetail({
    required this.batch,
    required this.id,
    required this.machineId,
    required this.productionOrderId,
    required this.status,
  });

  factory MachineDetail.fromJson(Map<String, dynamic> json) {
    return MachineDetail(
      batch: json['batch'] as String,
      id: json['id'] as String,
      machineId: json['machine_id'] as String,
      productionOrderId: json['production_order_id'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch': batch,
      'id': id,
      'machine_id': machineId,
      'production_order_id': productionOrderId,
      'status': status,
    };
  }
}
