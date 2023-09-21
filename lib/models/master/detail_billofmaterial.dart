class BomDetail {
  String bomId;
  String id;
  int jumlah;
  String materialId;
  String batch;
  String satuan;
  int status;

  BomDetail({
    required this.bomId,
    required this.id,
    required this.jumlah,
    required this.materialId,
    required this.batch,
    required this.satuan,
    required this.status,
  });

  factory BomDetail.fromJson(Map<String, dynamic> json) {
    return BomDetail(
      bomId: json['bom_id'] as String,
      id: json['id'] as String,
      jumlah: json['jumlah'] as int,
      materialId: json['material_id'] as String,
      batch: json['batch'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bom_id': bomId,
      'id': id,
      'jumlah': jumlah,
      'material_id': materialId,
      'batch': batch,
      'satuan': satuan,
      'status': status,
    };
  }
}
