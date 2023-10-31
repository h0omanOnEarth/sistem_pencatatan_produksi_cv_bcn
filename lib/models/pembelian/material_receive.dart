class MaterialReceive {
  final String id;
  final String purchaseRequestId;
  final String materialId;
  final String supplierId;
  final String satuan;
  final int jumlahPermintaan;
  final int jumlahDiterima;
  final int status;
  final String catatan;
  final DateTime tanggalPenerimaan;

  MaterialReceive({
    required this.id,
    required this.purchaseRequestId,
    required this.materialId,
    required this.supplierId,
    required this.satuan,
    required this.jumlahPermintaan,
    required this.jumlahDiterima,
    required this.status,
    required this.catatan,
    required this.tanggalPenerimaan,
  });

  factory MaterialReceive.fromJson(Map<String, dynamic> json) {
    return MaterialReceive(
      id: json['id'] as String,
      purchaseRequestId: json['purchase_request_id'] as String,
      materialId: json['material_id'] as String,
      supplierId: json['supplier_id'] as String,
      satuan: json['satuan'] as String,
      jumlahPermintaan: json['jumlah_permintaan'] as int,
      jumlahDiterima: json['jumlah_diterima'] as int,
      status: json['status'] as int, // Provide a default value of 0
      catatan: json['catatan'] as String,
      tanggalPenerimaan: DateTime.parse(json['tanggal_penerimaan'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_request_id': purchaseRequestId,
      'material_id': materialId,
      'supplier_id': supplierId,
      'satuan': satuan,
      'jumlah_permintaan': jumlahPermintaan,
      'jumlah_diterima': jumlahDiterima,
      'status': status,
      'catatan': catatan,
      'tanggal_penerimaan': tanggalPenerimaan.toIso8601String(),
    };
  }
}
