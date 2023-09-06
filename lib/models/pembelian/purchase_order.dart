class PurchaseOrder {
  final String id;
  final String supplierId;
  final String materialId;
  final int jumlah;
  final String satuan;
  final int hargaSatuan;
  final DateTime tanggalPesan;
  final DateTime tanggalKirim;
  final String statusPembayaran;
  final String statusPengiriman;
  final String keterangan;
  final int status;
  final int total;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.materialId,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    required this.tanggalPesan,
    required this.tanggalKirim,
    required this.statusPembayaran,
    required this.statusPengiriman,
    required this.keterangan,
    required this.status,
    required this.total,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      supplierId: json['supplier_id'],
      materialId: json['material_id'],
      jumlah: json['jumlah'],
      satuan: json['satuan'],
      hargaSatuan: int.parse(json['harga_satuan'].toString()),
      tanggalPesan: json['tanggal_pesan'],
      tanggalKirim: json['tanggal_kirim'],
      statusPembayaran: json['status_pembayaran'],
      statusPengiriman: json['status_pengiriman'],
      keterangan: json['keterangan'],
      status: json['status'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'material_id': materialId,
      'jumlah': jumlah,
      'satuan': satuan,
      'harga_satuan': hargaSatuan,
      'tanggal_pesan': tanggalPesan,
      'tanggal_kirim': tanggalKirim,
      'status_pembayaran': statusPembayaran,
      'status_pengiriman': statusPengiriman,
      'keterangan': keterangan,
      'status': status,
      'total': total,
    };
  }
}
