import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_request.dart';

class MaterialRequest {
  String id;
  String productionOrderId;
  int status;
  String statusMr;
  DateTime tanggalPermintaan;
  List<DetailMaterialRequest> detailMaterialRequestList;
  String catatan;

  MaterialRequest({
    required this.id,
    required this.productionOrderId,
    required this.status,
    required this.statusMr,
    required this.tanggalPermintaan,
    required this.catatan,
    this.detailMaterialRequestList = const [],
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailMaterialRequestData =
        json['detail_material_request_list'] as List<dynamic>;

    final List<DetailMaterialRequest> detailMaterialRequests =
        detailMaterialRequestData
            .map((dynamic data) =>
                DetailMaterialRequest.fromJson(data as Map<String, dynamic>))
            .toList();

    return MaterialRequest(
      id: json['id'] as String,
      productionOrderId: json['production_order_id'] as String,
      status: json['status'] as int,
      statusMr: json['status_mr'] as String,
      tanggalPermintaan: DateTime.parse(json['tanggal_permintaan'] as String),
      catatan: json['catatan'] as String,
      detailMaterialRequestList: detailMaterialRequests,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailMaterialRequestData =
        detailMaterialRequestList.map((DetailMaterialRequest detail) =>
            detail.toJson()).toList();

    return {
      'id': id,
      'production_order_id': productionOrderId,
      'status': status,
      'status_mr': statusMr,
      'tanggal_permintaan': tanggalPermintaan.toIso8601String(),
      'catatan': catatan,
      'detail_material_request_list': detailMaterialRequestData,
    };
  }
}
