class PurchaseReturn {
  final String id;
  final String purchaseOrderId;
  final int jumlah;
  final String satuan;
  final String alamatPengembalian;
  final String alasan;
  final int status;
  final DateTime tanggalPengembalian;
  final String jenis_bahan;
  final String keterangan;

  PurchaseReturn({
    required this.id,
    required this.purchaseOrderId,
    required this.jumlah,
    required this.satuan,
    required this.alamatPengembalian,
    required this.alasan,
    required this.status,
    required this.tanggalPengembalian,
    required this.jenis_bahan,
    required this.keterangan
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) {
    return PurchaseReturn(
      id: json['id'] ?? '',
      purchaseOrderId: json['purchase_order_id'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? '',
      alamatPengembalian: json['alamat_pengembalian'] ?? '',
      alasan: json['alasan'] ?? '',
      status: json['status'] ?? 0,
      tanggalPengembalian: DateTime.tryParse(json['tanggal_pengembalian'] ?? '') ?? DateTime.now(),
      jenis_bahan: json['jenis_bahan'],
      keterangan: json['keterangan']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_id': purchaseOrderId,
      'jumlah': jumlah,
      'satuan': satuan,
      'alamat_pengembalian': alamatPengembalian,
      'alasan': alasan,
      'status': status,
      'tanggal_pengembalian': tanggalPengembalian.toIso8601String(),
      'jenis_bahan': jenis_bahan,
      'keterangan': keterangan
    };
  }
}
