import 'detail_invoice.dart'; // Mengimpor model DetailInvoice

class Invoice {
  final String id;
  final String metodePembayaran;
  final String nomorRekening;
  final String shipmentId;
  final DateTime tanggalPembuatan;
  final int status;
  final int total;
  final int totalProduk;
  final String statusFk;
  final String statusPembayaran;
  final String catatan;
  final List<DetailInvoice> detailInvoices; // Daftar Detail Invoice

  Invoice({
    required this.id,
    required this.metodePembayaran,
    required this.nomorRekening,
    required this.shipmentId,
    required this.status,
    required this.statusFk,
    required this.total,
    required this.totalProduk,
    required this.tanggalPembuatan,
    required this.statusPembayaran,
    required this.catatan,
    this.detailInvoices = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailInvoiceListJson = json['detail_invoices'];
    final List<DetailInvoice> detailInvoices = detailInvoiceListJson
        .map((detailInvoiceJson) =>
            DetailInvoice.fromJson(detailInvoiceJson))
        .toList();

    return Invoice(
      id: json['id'] as String,
      metodePembayaran: json['metode_pembayaran'] as String,
      nomorRekening: json['nomor_rekening'] as String,
      shipmentId: json['shipment_id'] as String,
      status: json['status'] as int,
      total: json['total'] as int,
      totalProduk: json['total_produk'] as int,
      statusFk: json['status_fk'] as String,
      statusPembayaran: json['status_pembayaran'] as String,
      tanggalPembuatan: DateTime.parse(json['tanggal_pembuatan'] as String),
      catatan: json['catatan'] as String,
      detailInvoices: detailInvoices,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailInvoiceListJson =
        detailInvoices.map((detailInvoice) => detailInvoice.toJson()).toList();

    return {
      'id': id,
      'metode_pembayaran': metodePembayaran,
      'nomor_rekening': nomorRekening,
      'shipment_id': shipmentId,
      'status': status,
      'total': total,
      'total_produk': totalProduk,
      'status_fk': statusFk,
      'status_pembayaran': statusPembayaran,
      'tanggal_pembuatan': tanggalPembuatan.toIso8601String(),
      'catatan': catatan,
      'detail_invoices': detailInvoiceListJson,
    };
  }
}
