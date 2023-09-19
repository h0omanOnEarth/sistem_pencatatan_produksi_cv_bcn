class MaterialReturnDetail {
  String id;
  String jumlah;
  String materialId;
  String materialReturnId;
  String satuan;
  String status;

  MaterialReturnDetail({
    required this.id,
    required this.jumlah,
    required this.materialId,
    required this.materialReturnId,
    required this.satuan,
    required this.status,
  });

  factory MaterialReturnDetail.fromJson(Map<String, dynamic> json) {
    return MaterialReturnDetail(
      id: json['id'] as String,
      jumlah: json['jumlah'] as String,
      materialId: json['material_id'] as String,
      materialReturnId: json['material_return_id'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah': jumlah,
      'material_id': materialId,
      'material_return_id': materialReturnId,
      'satuan': satuan,
      'status': status,
    };
  }
}
