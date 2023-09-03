class Bahan {
  final String jenisBahan;
  final String keterangan;
  final String nama;
  final String satuan;
  final int status;
  final int stok;

  Bahan({
    required this.jenisBahan,
    required this.keterangan,
    required this.nama,
    required this.satuan,
    required this.status,
    required this.stok,
  });

  factory Bahan.fromJson(Map<String, dynamic> json) {
    return Bahan(
      jenisBahan: json['jenis_bahan'] ?? '',
      keterangan: json['keterangan'] ?? '',
      nama: json['nama'] ?? '',
      satuan: json['satuan'] ?? '',
      status: json['status'] ?? '',
      stok: (json['stok'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis_bahan': jenisBahan,
      'keterangan': keterangan,
      'nama': nama,
      'satuan': satuan,
      'status': status,
      'stok': stok,
    };
  }
}
