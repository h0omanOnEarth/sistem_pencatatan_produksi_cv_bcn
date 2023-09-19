class MaterialReturn {
  String id;
  String materialUsageId;
  String catatan;
  int status;
  String statusMrt;
  DateTime tanggalPengembalian;
  List<MaterialReturnDetail> detailMaterialReturn;

  MaterialReturn({
    required this.id,
    required this.materialUsageId,
    required this.catatan,
    required this.status,
    required this.statusMrt,
    required this.tanggalPengembalian,
    this.detailMaterialReturn = const [],
  });

  factory MaterialReturn.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailJson = json['detailMaterialReturn'] ?? [];
    final List<MaterialReturnDetail> detailMaterialReturn =
        detailJson.map((data) => MaterialReturnDetail.fromJson(data)).toList();

    return MaterialReturn(
      id: json['id'] as String,
      materialUsageId: json['material_usage_id'] as String,
      catatan: json['catatan'] as String,
      status: json['status'] as int,
      statusMrt: json['status_mrt'] as String,
      tanggalPengembalian:
          DateTime.parse(json['tanggal_pengembalian'] as String),
      detailMaterialReturn: detailMaterialReturn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_usage_id': materialUsageId,
      'catatan': catatan,
      'status': status,
      'status_mrt': statusMrt,
      'tanggal_pengembalian': tanggalPengembalian.toUtc().toIso8601String(),
      'detailMaterialReturn':
          detailMaterialReturn.map((detail) => detail.toJson()).toList(),
    };
  }
}

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
