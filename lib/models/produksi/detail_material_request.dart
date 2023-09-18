class DetailMaterialRequest {
  String id;
  int jumlahBom;
  String materialId;
  String materialRequestId;
  String satuan;
  String batch;
  int status;

  DetailMaterialRequest({
    required this.id,
    required this.jumlahBom,
    required this.materialId,
    required this.materialRequestId,
    required this.satuan,
    required this.batch,
    required this.status,
  });

  factory DetailMaterialRequest.fromJson(Map<String, dynamic> json) {
    return DetailMaterialRequest(
      id: json['id'] as String,
      jumlahBom: json['jumlah_bom'] as int,
      materialId: json['material_id'] as String,
      materialRequestId: json['material_request_id'] as String,
      satuan: json['satuan'] as String,
      batch: json['batch'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah_bom': jumlahBom,
      'material_id': materialId,
      'material_request_id': materialRequestId,
      'satuan': satuan,
      'batch' :batch,
      'status': status,
    };
  }
}
