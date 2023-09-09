class DetailCustomerOrder {
  final String id;
  String customerOrderId;
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
