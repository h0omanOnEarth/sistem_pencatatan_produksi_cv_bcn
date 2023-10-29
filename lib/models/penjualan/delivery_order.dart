import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_delivery_order.dart';

class DeliveryOrder {
  String id;
  String customerOrderId;
  String metodePengiriman;
  String satuan;
  String alamatPengiriman;
  String catatan;
  int status;
  String statusPesananPengiriman;
  DateTime tanggalPesananPengiriman;
  DateTime tanggalRequestPengiriman;
  int totalBarang;
  int totalHarga;
  int estimasiWaktu;
  List<DetailDeliveryOrder>?
      detailDeliveryOrderList; // List tidak perlu menjadi opsional

  DeliveryOrder({
    required this.id,
    required this.customerOrderId,
    required this.metodePengiriman,
    required this.alamatPengiriman,
    required this.satuan,
    required this.catatan,
    required this.status,
    required this.statusPesananPengiriman,
    required this.tanggalPesananPengiriman,
    required this.tanggalRequestPengiriman,
    required this.totalBarang,
    required this.totalHarga,
    required this.estimasiWaktu,
    this.detailDeliveryOrderList = const [], // Initialize the list
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      catatan: json['catatan'],
      customerOrderId: json['customer_order_id'] as String,
      metodePengiriman: json['metode_pengiriman'] as String,
      satuan: json['satuan'] as String,
      alamatPengiriman: json['alamat_pengiriman'] as String,
      status: json['status'] as int,
      statusPesananPengiriman: json['status_pesanan_pengiriman'] as String,
      tanggalPesananPengiriman:
          DateTime.parse(json['tanggal_pesanan_pengiriman'] as String),
      tanggalRequestPengiriman:
          DateTime.parse(json['tanggal_request_pengiriman'] as String),
      totalBarang: json['total_barang'] as int,
      totalHarga: json['total_harga'] as int,
      estimasiWaktu: json['estimasi_waktu'] as int,
    );
  }

  Future<void> fetchDetailDeliveryOrders() async {
    final detailDeliveryOrdersQuery = FirebaseFirestore.instance
        .collection('detail_delivery_orders')
        .where('delivery_order_id', isEqualTo: id);

    final detailDeliveryOrdersSnapshot = await detailDeliveryOrdersQuery.get();
    final detailDeliveryOrdersData =
        detailDeliveryOrdersSnapshot.docs.map((doc) {
      final data = doc.data();
      return DetailDeliveryOrder.fromJson(data);
    }).toList();

    detailDeliveryOrderList = detailDeliveryOrdersData;
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? detailDeliveryOrderJson =
        detailDeliveryOrderList?.map((detail) {
      return detail.toJson();
    }).toList();

    return {
      'id': id,
      'customer_order_id': customerOrderId,
      'metode_pengiriman': metodePengiriman,
      'alamat_pengiriman': alamatPengiriman,
      'satuan': satuan,
      'status': status,
      'catatan': catatan,
      'status_pesanan_pengiriman': statusPesananPengiriman,
      'tanggal_pesanan_pengiriman': tanggalPesananPengiriman.toIso8601String(),
      'tanggal_request_pengiriman': tanggalRequestPengiriman.toIso8601String(),
      'total_barang': totalBarang,
      'total_harga': totalHarga,
      'estimasi_waktu': estimasiWaktu,
      'detail_delivery_order': detailDeliveryOrderJson,
    };
  }
}
