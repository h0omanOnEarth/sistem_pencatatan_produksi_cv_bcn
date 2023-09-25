class DetailInvoice {
  final String id;
  final String invoiceId;
  final String productId;
  final int harga;
  final int jumlahPengiriman;
  final int jumlahPengirimanDus;
  final int subtotal;
  final int status;

  DetailInvoice({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.harga,
    required this.jumlahPengiriman,
    required this.jumlahPengirimanDus,
    required this.subtotal,
    required this.status,
  });

  factory DetailInvoice.fromJson(Map<String, dynamic> json) {
    return DetailInvoice(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      productId: json['product_id'] as String,
      harga: (json['harga'] as num).toInt(),
      jumlahPengiriman: json['jumlah_pengiriman'] as int,
      jumlahPengirimanDus: json['jumlah_pengiriman_dus'] as int,
      subtotal: (json['subtotal'] as num).toInt(),
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'harga': harga,
      'jumlah_pengiriman': jumlahPengiriman,
      'jumlah_pengiriman_dus': jumlahPengirimanDus,
      'subtotal': subtotal,
      'status': status,
    };
  }
}
