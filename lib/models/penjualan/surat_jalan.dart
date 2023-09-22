import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_surat_jalan.dart';

class Shipment {
  final String id;
  final String alamatPenerima;
  final String catatan;
  final String deliveryOrderId;
  final int status;
  final String statusShp;
  final DateTime tanggalPembuatan;
  final List<DetailShipment> detailListShipment;

  Shipment({
    required this.id,
    required this.alamatPenerima,
    required this.catatan,
    required this.deliveryOrderId,
    required this.status,
    required this.statusShp,
    required this.tanggalPembuatan,
    this.detailListShipment = const [],
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailShipmentJson = json['detailListShipment'];

    List<DetailShipment> detailListShipment = [];
    for (final detailJson in detailShipmentJson) {
      final detailShipment = DetailShipment.fromJson(detailJson);
      detailListShipment.add(detailShipment);
    }

    return Shipment(
      id: json['id'] as String,
      alamatPenerima: json['alamat_penerima'] as String,
      catatan: json['catatan'] as String,
      deliveryOrderId: json['delivery_order_id'] as String,
      status: json['status'] as int,
      statusShp: json['status_shp'] as String,
      tanggalPembuatan: DateTime.parse(json['tanggal_pembuatan'] as String),
      detailListShipment: detailListShipment,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailShipmentJson = detailListShipment.map((detail) => detail.toJson()).toList();

    return {
      'id': id,
      'alamat_penerima': alamatPenerima,
      'catatan': catatan,
      'delivery_order_id': deliveryOrderId,
      'status': status,
      'status_shp': statusShp,
      'tanggal_pembuatan': tanggalPembuatan.toIso8601String(),
      'detailListShipment': detailShipmentJson,
    };
  }
}
