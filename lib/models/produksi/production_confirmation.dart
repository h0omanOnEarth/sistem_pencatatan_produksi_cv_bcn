import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_production_confirmation.dart';

class ProductionConfirmation {
  String id;
  String catatan;
  int status;
  String statusPrc;
  DateTime tanggalKonfirmasi;
  int total;
  List<DetailProductionConfirmation> detailProductionConfirmations;

  ProductionConfirmation({
    required this.id,
    required this.catatan,
    required this.status,
    required this.statusPrc,
    required this.tanggalKonfirmasi,
    required this.total,
    this.detailProductionConfirmations = const [],
  });

  factory ProductionConfirmation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailsJson = json['details'] as List<dynamic>;

    return ProductionConfirmation(
      id: json['id'] as String,
      catatan: json['catatan'] as String,
      status: json['status'] as int,
      statusPrc: json['status_prc'] as String,
      tanggalKonfirmasi: DateTime.parse(json['tanggal_konfirmasi'] as String),
      total: json['total'] as int,
      detailProductionConfirmations: detailsJson.map((detailJson) {
        return DetailProductionConfirmation.fromJson(
            detailJson as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailsJson =
        detailProductionConfirmations.map((detail) {
      return detail.toJson();
    }).toList();

    return {
      'id': id,
      'catatan': catatan,
      'status': status,
      'status_prc': statusPrc,
      'tanggal_konfirmasi': tanggalKonfirmasi.toIso8601String(),
      'total': total,
      'details': detailsJson,
    };
  }
}
