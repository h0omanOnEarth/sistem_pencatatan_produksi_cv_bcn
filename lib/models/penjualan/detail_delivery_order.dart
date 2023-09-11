class DetailDeliveryOrder {
  String id;
  String deliveryOrderId;
  String product_id;
  int jumlah;
  String satuan;
  int hargaSatuan;
  int status;
  int subtotal;

  DetailDeliveryOrder({
    required this.id,
    required this.deliveryOrderId,
    required this.product_id,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    required this.status,
    required this.subtotal,
  });

  factory DetailDeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DetailDeliveryOrder(
      id: json['id'] as String,
      deliveryOrderId: json['delivery_order_id'] as String,
      product_id: json['product_id'] as String,
      jumlah: json['jumlah'] as int,
      satuan: json['satuan'] as String,
      hargaSatuan: json['harga_satuan'] as int,
      status: json['status'] as int,
      subtotal: json['subtotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_order_id': deliveryOrderId,
      'product_id': product_id,
      'jumlah': jumlah,
      'satuan': satuan,
      'harga_satuan': hargaSatuan,
      'status': status,
      'subtotal': subtotal,
    };
  }
}
