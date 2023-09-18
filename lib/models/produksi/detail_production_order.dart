class DetailProductionOrder {
  String id;
  int jumlahBOM;
  String materialId;
  String productionOrderId;
  String batch;
  String satuan;
  int status;

  DetailProductionOrder({
    required this.id,
    required this.jumlahBOM,
    required this.materialId,
    required this.productionOrderId,
    required this.batch,
    required this.satuan,
    required this.status,
  });

  factory DetailProductionOrder.fromJson(Map<String, dynamic> json) {
    return DetailProductionOrder(
      id: json['id'] as String,
      jumlahBOM: json['jumlah_bom'] as int,
      materialId: json['material_id'] as String,
      productionOrderId: json['production_order_id'] as String,
      batch: json['batch'],
      satuan: json['satuan'],
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah_bom': jumlahBOM,
      'material_id': materialId,
      'production_order_id': productionOrderId,
      'batch' : batch,
      'satuan': satuan,
      'status': status,
    };
  }
}
