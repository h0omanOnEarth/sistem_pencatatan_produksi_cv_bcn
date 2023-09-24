class MaterialTransforms {
  String id;
  String catatan;
  int jumlahBarangGagal;
  int jumlahHasil;
  String machineId;
  String satuan;
  String satuanHasil;
  String satuanTotalHasil;
  int status;
  String statusMtf;
  DateTime tanggalPengubahan;
  int totalHasil;

  MaterialTransforms({
    required this.id,
    required this.catatan,
    required this.jumlahBarangGagal,
    required this.jumlahHasil,
    required this.machineId,
    required this.satuan,
    required this.satuanHasil,
    required this.satuanTotalHasil,
    required this.status,
    required this.statusMtf,
    required this.tanggalPengubahan,
    required this.totalHasil,
  });

  factory MaterialTransforms.fromJson(Map<String, dynamic> json) {
    return MaterialTransforms(
      id: json['id'] as String,
      catatan: json['catatan'] as String,
      jumlahBarangGagal: json['jumlah_barang_gagal'] as int,
      jumlahHasil: json['jumlah_hasil'] as int,
      machineId: json['machine_id'] as String,
      satuan: json['satuan'] as String,
      satuanHasil: json['satuan_hasil'] as String,
      satuanTotalHasil: json['satuan_total_hasil'] as String,
      status: json['status'] as int,
      statusMtf: json['status_mtf'] as String,
      tanggalPengubahan: DateTime.parse(json['tanggal_pengubahan'] as String),
      totalHasil: json['total_hasil'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catatan': catatan,
      'jumlah_barang_gagal': jumlahBarangGagal,
      'jumlah_hasil': jumlahHasil,
      'machine_id': machineId,
      'satuan': satuan,
      'satuan_hasil': satuanHasil,
      'satuan_total_hasil': satuanTotalHasil,
      'status': status,
      'status_mtf': statusMtf,
      'tanggal_pengubahan': tanggalPengubahan.toIso8601String(),
      'total_hasil': totalHasil,
    };
  }
}
