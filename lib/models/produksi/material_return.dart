import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_return.dart';

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
