import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_pesanan_pelanggan.dart';

class CustomerOrder {
  final String id;
  final String customerId;
  final String alamatPengiriman;
  final String catatan;
  final String satuan;
  final int status;
  final String statusPesanan;
  final DateTime tanggalKirim;
  final DateTime tanggalPesan;
  final int totalHarga;
  final int totalProduk;
  List<DetailCustomerOrder>?
      detailCustomerOrderList; // List tidak perlu menjadi opsional

  CustomerOrder({
    required this.id,
    required this.customerId,
    required this.alamatPengiriman,
    required this.catatan,
    required this.satuan,
    required this.status,
    required this.statusPesanan,
    required this.tanggalKirim,
    required this.tanggalPesan,
    required this.totalHarga,
    required this.totalProduk,
    this.detailCustomerOrderList = const [], // Initialize the list
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      alamatPengiriman: json['alamat_pengiriman'] as String,
      catatan: json['catatan'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
      statusPesanan: json['status_pesanan'] as String,
      tanggalKirim: (json['tanggal_kirim'] as Timestamp).toDate(),
      tanggalPesan: (json['tanggal_pesan'] as Timestamp).toDate(),
      totalHarga: json['total_harga'] as int,
      totalProduk: json['total_produk'] as int,
    );
  }

  Future<void> fetchDetailCustomerOrders() async {
    final detailCustomerOrdersQuery = FirebaseFirestore.instance
        .collection('detail_customer_order')
        .where('customer_order_id', isEqualTo: id);

    final detailCustomerOrdersSnapshot = await detailCustomerOrdersQuery.get();
    final detailCustomerOrdersData =
        detailCustomerOrdersSnapshot.docs.map((doc) {
      final data = doc.data();
      return DetailCustomerOrder.fromJson(data);
    }).toList();

    detailCustomerOrderList = detailCustomerOrdersData;
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? detailCustomerOrderJson =
        detailCustomerOrderList?.map((detail) {
      return detail.toJson();
    }).toList();

    return {
      'id': id,
      'customer_id': customerId,
      'alamat_pengiriman': alamatPengiriman,
      'catatan': catatan,
      'satuan': satuan,
      'status': status,
      'status_pesanan': statusPesanan,
      'tanggal_kirim': tanggalKirim,
      'tanggal_pesan': tanggalPesan,
      'total_harga': totalHarga,
      'total_produk': totalProduk,
      'detail_customer_order': detailCustomerOrderJson,
    };
  }
}
