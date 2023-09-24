class DetailShipment {
  final String id;
  final String shipmentId;
  final int jumlahDusPesanan;
  final int jumlahPengiriman;
  final int jumlahPengirimanDus;
  final int jumlahPesanan;
  final String productId;
  final int status;

  DetailShipment({
    required this.id,
    required this.shipmentId,
    required this.jumlahDusPesanan,
    required this.jumlahPengiriman,
    required this.jumlahPengirimanDus,
    required this.jumlahPesanan,
    required this.productId,
    required this.status,
  });

  factory DetailShipment.fromJson(Map<String, dynamic> json) {
    return DetailShipment(
      id: json['id'] as String,
      shipmentId: json['shipment_id'] as String,
      jumlahDusPesanan: json['jumlah_dus_pesanan'] as int,
      jumlahPengiriman: json['jumlah_pengiriman'] as int,
      jumlahPengirimanDus: json['jumlah_pengiriman_dus'] as int,
      jumlahPesanan: json['jumlah_pesanan'] as int,
      productId: json['product_id'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'jumlah_dus_pesanan': jumlahDusPesanan,
      'jumlah_pengiriman': jumlahPengiriman,
      'jumlah_pengiriman_dus': jumlahPengirimanDus,
      'jumlah_pesanan': jumlahPesanan,
      'product_id': productId,
      'status': status,
    };
  }
}
