class Mesin {
  final String id;
  final int kapasitasProduksi;
  final String keterangan;
  final String kondisi;
  final String nama;
  final String nomorSeri;
  final String satuan;
  final int status;
  final String supplierId;
  final int tahunPembuatan;
  final int tahunPerolehan;
  final String tipe;

  Mesin({
    required this.id,
    required this.kapasitasProduksi,
    required this.keterangan,
    required this.kondisi,
    required this.nama,
    required this.nomorSeri,
    required this.satuan,
    required this.status,
    required this.supplierId,
    required this.tahunPembuatan,
    required this.tahunPerolehan,
    required this.tipe,
  });

  factory Mesin.fromJson(Map<String, dynamic> json) {
    return Mesin(
      id: json['id'] ?? "",
      kapasitasProduksi: json['kapasitas_produksi'] ?? 0,
      keterangan: json['keterangan'] ?? "",
      kondisi: json['kondisi'] ?? "",
      nama: json['nama'] ?? "",
      nomorSeri: json['nomor_seri'] ?? "",
      satuan: json['satuan'] ?? "",
      status: json['status'] ?? 0,
      supplierId: json['supplier_id'] ?? "",
      tahunPembuatan: json['tahun_pembuatan'] ?? 0,
      tahunPerolehan: json['tahun_perolehan'] ?? 0,
      tipe: json['tipe'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'kapasitas_produksi': kapasitasProduksi,
      'keterangan': keterangan,
      'kondisi': kondisi,
      'nama': nama,
      'nomor_seri': nomorSeri,
      'satuan': satuan,
      'status': status,
      'supplier_id': supplierId,
      'tahun_pembuatan': tahunPembuatan,
      'tahun_perolehan': tahunPerolehan,
      'tipe': tipe,
    };
  }
}
