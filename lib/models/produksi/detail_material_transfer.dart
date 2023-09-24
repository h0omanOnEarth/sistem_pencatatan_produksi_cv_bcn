class MaterialTransferDetail {
  final String id;
  final int jumlahBom;
  final String materialId;
  final String materialTransferId;
  final String satuan;
  final int status;
  final int stok;

  MaterialTransferDetail({
    required this.id,
    required this.jumlahBom,
    required this.materialId,
    required this.materialTransferId,
    required this.satuan,
    required this.status,
    required this.stok,
  });

  factory MaterialTransferDetail.fromJson(Map<String, dynamic> json) {
    return MaterialTransferDetail(
      id: json['id'] ?? '',
      jumlahBom: json['jumlah'] ?? 0,
      materialId: json['material_id'] ?? '',
      materialTransferId: json['material_transfer_id'] ?? '',
      satuan: json['satuan'] ?? '',
      status: json['status'] ?? 0,
      stok: json['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah': jumlahBom,
      'material_id': materialId,
      'material_transfer_id': materialTransferId,
      'satuan': satuan,
      'status': status,
      'stok': stok,
    };
  }
}
