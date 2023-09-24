import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_customer_order_return.dart';

class CustomerOrderReturn {
  final String alasanPengembalian;
  final String catatan;
  final String id;
  final String invoiceId;
  final int status;
  final DateTime tanggalPengembalian;
  final List<DetailCustomerOrderReturn> detailCustomerOrderReturnList;

  CustomerOrderReturn({
    required this.alasanPengembalian,
    required this.catatan,
    required this.id,
    required this.invoiceId,
    required this.status,
    required this.tanggalPengembalian,
    this.detailCustomerOrderReturnList = const [],
  });

  factory CustomerOrderReturn.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailJsonList = json['detailCustomerOrderReturnList'] ?? [];
    final List<DetailCustomerOrderReturn> detailList = detailJsonList
        .map((detailJson) => DetailCustomerOrderReturn.fromJson(detailJson))
        .toList();

    return CustomerOrderReturn(
      alasanPengembalian: json['alasan_pengembalian'] ?? '',
      catatan: json['catatan'] ?? '',
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      status: json['status'] ?? 0,
      tanggalPengembalian: DateTime.parse(json['tanggal_pengembalian'] ?? ''),
      detailCustomerOrderReturnList: detailList,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailJsonList = detailCustomerOrderReturnList
        .map((detail) => detail.toJson())
        .toList();

    return {
      'alasan_pengembalian': alasanPengembalian,
      'catatan': catatan,
      'id': id,
      'invoice_id': invoiceId,
      'status': status,
      'tanggal_pengembalian': tanggalPengembalian.toIso8601String(),
      'detailCustomerOrderReturnList': detailJsonList,
    };
  }
}
