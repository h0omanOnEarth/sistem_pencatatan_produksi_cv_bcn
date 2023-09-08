import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrder {
  final String id;
  final String customerOrderId;
  final String alamatPengiriman;
  final String catatan;
  final String satuan;
  final int status;
  final String statusPesanan;
  final DateTime tanggalKirim;
  final DateTime tanggalPesan;
  final int totalHarga;
  final int totalProduk;
  final List<DetailCustomerOrder> detailCustomerOrderList;

  CustomerOrder({
    required this.id,
    required this.customerOrderId,
    required this.alamatPengiriman,
    required this.catatan,
    required this.satuan,
    required this.status,
    required this.statusPesanan,
    required this.tanggalKirim,
    required this.tanggalPesan,
    required this.totalHarga,
    required this.totalProduk,
    required this.detailCustomerOrderList,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailCustomerOrderJson = json['detail_customer_order'] ?? [];
    final List<DetailCustomerOrder> detailCustomerOrderList =
        detailCustomerOrderJson.map((detailJson) {
      return DetailCustomerOrder.fromJson(detailJson as Map<String, dynamic>);
    }).toList();

    return CustomerOrder(
      id: json['id'] as String,
      customerOrderId: json['customer_order_id'] as String,
      alamatPengiriman: json['alamat_pengiriman'] as String,
      catatan: json['catatan'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
      statusPesanan: json['status_pesanan'] as String,
      tanggalKirim: (json['tanggal_kirim'] as Timestamp).toDate(),
      tanggalPesan: (json['tanggal_pesan'] as Timestamp).toDate(),
      totalHarga: json['total_harga'] as int,
      totalProduk: json['total_produk'] as int,
      detailCustomerOrderList: detailCustomerOrderList,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailCustomerOrderJson =
        detailCustomerOrderList.map((detail) {
      return detail.toJson();
    }).toList();

    return {
      'id': id,
      'customer_order_id': customerOrderId,
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

class DetailCustomerOrder {
  final String id;
  final String customerOrderId;
  final String productId;
  final int jumlah;
  final int hargaSatuan;
  final String satuan;
  final int status;
  final int subtotal;

  DetailCustomerOrder({
    required this.id,
    required this.customerOrderId,
    required this.productId,
    required this.jumlah,
    required this.hargaSatuan,
    required this.satuan,
    required this.status,
    required this.subtotal,
  });

  factory DetailCustomerOrder.fromJson(Map<String, dynamic> json) {
    return DetailCustomerOrder(
      id: json['id'] as String,
      customerOrderId: json['customer_order_id'] as String,
      productId: json['product_id'] as String,
      jumlah: json['jumlah'] as int,
      hargaSatuan: json['harga_satuan'] as int,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
      subtotal: json['subtotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_order_id': customerOrderId,
      'product_id': productId,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'satuan': satuan,
      'status': status,
      'subtotal': subtotal,
    };
  }
}
