class DetailCustomerOrderReturn {
  final String customerOrderReturnId;
  final String id;
  final int jumlahPengembalian;
  final int jumlahPesanan;
  final String productId;
  final int status;

  DetailCustomerOrderReturn({
    required this.customerOrderReturnId,
    required this.id,
    required this.jumlahPengembalian,
    required this.jumlahPesanan,
    required this.productId,
    required this.status,
  });

  factory DetailCustomerOrderReturn.fromJson(Map<String, dynamic> json) {
    return DetailCustomerOrderReturn(
      customerOrderReturnId: json['customer_order_return_id'] ?? '',
      id: json['id'] ?? '',
      jumlahPengembalian: json['jumlah_pengembalian'] ?? 0,
      jumlahPesanan: json['jumlah_pesanan'] ?? 0,
      productId: json['product_id'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_order_return_id': customerOrderReturnId,
      'id': id,
      'jumlah_pengembalian': jumlahPengembalian,
      'jumlah_pesanan': jumlahPesanan,
      'product_id': productId,
      'status': status,
    };
  }
}
