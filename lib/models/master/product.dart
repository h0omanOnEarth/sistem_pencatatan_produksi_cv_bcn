class Product {
  final String id;
  final String nama;
  final String deskripsi;
  final String jenis;
  final String satuan;
  final double berat;
  final int dimensi;
  final int harga;
  final int ketebalan;
  final int status;
  final int stok;

  Product({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.jenis,
    required this.satuan,
    required this.berat,
    required this.dimensi,
    required this.harga,
    required this.ketebalan,
    required this.status,
    required this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jenis: json['jenis'] ?? '',
      satuan: json['satuan'] ?? '',
      berat: (json['berat'] as num).toDouble(),
      dimensi: json['dimensi'] ?? 0,
      harga: json['harga'] ?? 0,
      ketebalan: json['ketebalan'] ?? 0,
      status: json['status'] ?? 0,
      stok: json['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'jenis': jenis,
      'satuan': satuan,
      'berat': berat,
      'dimensi': dimensi,
      'harga': harga,
      'ketebalan': ketebalan,
      'status': status,
      'stok': stok,
    };
  }
}
