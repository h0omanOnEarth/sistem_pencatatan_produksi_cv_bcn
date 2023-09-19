class DetailMaterialUsage {
  String id;
  int jumlah;
  String materialId;
  String materialUsageId;
  String satuan;
  int status;

  DetailMaterialUsage({
    required this.id,
    required this.jumlah,
    required this.materialId,
    required this.materialUsageId,
    required this.satuan,
    required this.status,
  });

  factory DetailMaterialUsage.fromJson(Map<String, dynamic> json) {
    return DetailMaterialUsage(
      id: json['id'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      materialId: json['material_id'] ?? '',
      materialUsageId: json['material_usage_id'] ?? '',
      satuan: json['satuan'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah': jumlah,
      'material_id': materialId,
      'material_usage_id': materialUsageId,
      'satuan': satuan,
      'status': status,
    };
  }
}
