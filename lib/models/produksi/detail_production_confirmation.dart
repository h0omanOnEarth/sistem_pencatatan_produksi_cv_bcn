class DetailProductionConfirmation {
  String id;
  int jumlahKonfirmasi;
  String productionConfirmationId;
  String productionResultId;
  String satuan;
  int status;

  DetailProductionConfirmation({
    required this.id,
    required this.jumlahKonfirmasi,
    required this.productionConfirmationId,
    required this.productionResultId,
    required this.satuan,
    required this.status,
  });

  factory DetailProductionConfirmation.fromJson(Map<String, dynamic> json) {
    return DetailProductionConfirmation(
      id: json['id'] as String,
      jumlahKonfirmasi: json['jumlah_konfirmasi'] as int,
      productionConfirmationId: json['production_confirmation_id'] as String,
      productionResultId: json['production_result_id'] as String,
      satuan: json['satuan'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah_konfirmasi': jumlahKonfirmasi,
      'production_confirmation_id': productionConfirmationId,
      'production_result_id': productionResultId,
      'satuan' : satuan,
      'status': status,
    };
  }
}
