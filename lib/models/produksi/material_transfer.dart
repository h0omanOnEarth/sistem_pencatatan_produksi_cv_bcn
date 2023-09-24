import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_transfer.dart';

class MaterialTransfer {
  final String id;
  final String materialRequestId;
  final String statusMtr;
  final DateTime tanggalPemindahan;
  final String catatan;
  final int status;
  final List<MaterialTransferDetail> detailList;

  MaterialTransfer({
    required this.id,
    required this.materialRequestId,
    required this.statusMtr,
    required this.tanggalPemindahan,
    required this.catatan,
    required this.status,
    this.detailList = const [],
  });

  factory MaterialTransfer.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailJson = json['detailList'] ?? [];
    final List<MaterialTransferDetail> details = detailJson.map((item) {
      return MaterialTransferDetail.fromJson(item);
    }).toList();

    return MaterialTransfer(
      id: json['id'] ?? '',
      materialRequestId: json['material_request_id'] ?? '',
      statusMtr: json['status_mtr'] ?? '',
      tanggalPemindahan: DateTime.parse(json['tanggal_pemindahan'] as String),
      catatan: json['catatan'] ?? '',
      status: json['status'] ?? 0,
      detailList: details,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailListJson = detailList.map((detail) {
      return detail.toJson();
    }).toList();

    return {
      'id': id,
      'material_request_id': materialRequestId,
      'status_mtr': statusMtr,
      'tanggal_pemindahan': tanggalPemindahan,
      'catatan': catatan,
      'status': status,
      'detailList': detailListJson,
    };
  }
}
