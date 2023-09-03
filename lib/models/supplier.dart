class Supplier {
  final String? supplierId;
  final String alamat;
  final String email;
  final String jenisSupplier;
  final String nama;
  final String noTelepon;
  final String noTeleponKantor;
  final int status;

  Supplier({
    this.supplierId,
    required this.alamat,
    required this.email,
    required this.jenisSupplier,
    required this.nama,
    required this.noTelepon,
    required this.noTeleponKantor,
    required this.status
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplierId'] ?? '',
      alamat: json['alamat'] ?? '',
      email: json['email'] ?? '',
      jenisSupplier: json['jenis_supplier'] ?? '',
      nama: json['nama'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      noTeleponKantor: json['no_telepon_kantor'] ?? '',
      status:  json['status'] ?? 1
    );
  }
}
