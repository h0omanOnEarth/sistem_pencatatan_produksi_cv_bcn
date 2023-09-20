class ProductionResult {
  final String id;
  final String materialUsageId;
  final int totalProduk;
  final int jumlahProdukBerhasil;
  final int jumlahProdukCacat;
  final String satuan;
  final String catatan;
  final String statusPRS;
  final int status;
  final DateTime tanggalPencatatan;
  final int waktuProduksi;

  ProductionResult({
    required this.id,
    required this.materialUsageId,
    required this.totalProduk,
    required this.jumlahProdukBerhasil,
    required this.jumlahProdukCacat,
    required this.satuan,
    required this.catatan,
    required this.statusPRS,
    required this.status,
    required this.tanggalPencatatan,
    required this.waktuProduksi,
  });

  factory ProductionResult.fromJson(Map<String, dynamic> json) {
    return ProductionResult(
      id: json['id'] as String,
      materialUsageId: json['material_usage_id'] as String,
      totalProduk: json['total_produk'] as int,
      jumlahProdukBerhasil: json['jumlah_produk_berhasil'] as int,
      jumlahProdukCacat: json['jumlah_produk_cacat'] as int,
      satuan: json['satuan'] as String,
      catatan: json['catatan'] as String,
      statusPRS: json['status_prs'] as String,
      status: json['status'] as int,
      tanggalPencatatan: DateTime.parse(json['tanggal_pencatatan'] as String),
      waktuProduksi: json['waktu_produksi'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_usage_id': materialUsageId,
      'total_produk': totalProduk,
      'jumlah_produk_berhasil': jumlahProdukBerhasil,
      'jumlah_produk_cacat': jumlahProdukCacat,
      'satuan': satuan,
      'catatan': catatan,
      'status_prs': statusPRS,
      'status': status,
      'tanggal_pencatatan': tanggalPencatatan.toIso8601String(),
      'waktu_produksi': waktuProduksi,
    };
  }
}
