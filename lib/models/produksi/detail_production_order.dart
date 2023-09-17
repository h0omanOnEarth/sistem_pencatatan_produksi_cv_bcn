class DetailProductionOrder {
  String id;
  int jumlahBOM;
  String materialId;
  String productionOrderId;
  String satuan;
  String status;

  DetailProductionOrder({
    required this.id,
    required this.jumlahBOM,
    required this.materialId,
    required this.productionOrderId,
    required this.satuan,
    required this.status,
  });

  factory DetailProductionOrder.fromJson(Map<String, dynamic> json) {
    return DetailProductionOrder(
      id: json['id'] as String,
      jumlahBOM: json['jumlah_bom'] as int,
      materialId: json['material_id'] as String,
      productionOrderId: json['production_order_id'] as String,
      satuan: json['satuan'],
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah_bom': jumlahBOM,
      'material_id': materialId,
      'production_order_id': productionOrderId,
      'satuan': satuan,
      'status': status,
    };
  }
}
