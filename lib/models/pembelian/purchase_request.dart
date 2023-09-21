class PurchaseRequest {
  final String id;
  final String catatan;
  final int jumlah;
  final String materialId;
  final String satuan;
  final int status;
  final String statusPrq;
  final DateTime tanggalPermintaan;

  PurchaseRequest({
    required this.id,
    required this.catatan,
    required this.jumlah,
    required this.materialId,
    required this.satuan,
    required this.status,
    required this.statusPrq,
    required this.tanggalPermintaan,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      id: json['id'] as String,
      catatan: json['catatan'] as String,
      jumlah: json['jumlah'] as int,
      materialId: json['material_id'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
      statusPrq: json['status_prq'] as String,
      tanggalPermintaan: DateTime.parse(json['tanggal_permintaan'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catatan': catatan,
      'jumlah': jumlah,
      'material_id': materialId,
      'satuan': satuan,
      'status': status,
      'status_prq': statusPrq,
      'tanggal_permintaan': tanggalPermintaan.toUtc().toIso8601String(),
    };
  }
}
