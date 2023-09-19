import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_usage.dart';

class MaterialUsage {
  String batch;
  String catatan;
  String id;
  String productionOrderId;
  int status;
  String statusMu;
  DateTime tanggalPenggunaan;
  List<DetailMaterialUsage> detailMaterialUsageList;

  MaterialUsage({
    required this.batch,
    required this.catatan,
    required this.id,
    required this.productionOrderId,
    required this.status,
    required this.statusMu,
    required this.tanggalPenggunaan,
    this.detailMaterialUsageList = const [],
  });

  factory MaterialUsage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailMaterialUsageData = json['detail_material_usage_list'] ?? [];
    final List<DetailMaterialUsage> detailMaterialUsageList = detailMaterialUsageData.map((data) {
      return DetailMaterialUsage.fromJson(data);
    }).toList();

    return MaterialUsage(
      batch: json['batch'] ?? '',
      catatan: json['catatan'] ?? '',
      id: json['id'] ?? '',
      productionOrderId: json['production_order_id'] ?? '',
      status: json['status'] ?? 0,
      statusMu: json['status_mu'] ?? '',
      tanggalPenggunaan: DateTime.parse(json['tanggal_penggunaan'] ?? ''),
      detailMaterialUsageList: detailMaterialUsageList,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailMaterialUsageData =
        detailMaterialUsageList.map((detailMaterialUsage) => detailMaterialUsage.toJson()).toList();

    return {
      'batch': batch,
      'catatan': catatan,
      'id': id,
      'production_order_id': productionOrderId,
      'status': status,
      'status_mu': statusMu,
      'tanggal_penggunaan': tanggalPenggunaan.toUtc().toIso8601String(),
      'detail_material_usage_list': detailMaterialUsageData,
    };
  }
}
