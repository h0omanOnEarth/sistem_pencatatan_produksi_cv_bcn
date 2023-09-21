class Customer {
  final String id;
  final String nama;
  final String alamat;
  final String nomorTelepon;
  final String nomorTeleponKantor;
  final String email;
  final int status;

  Customer({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.nomorTelepon,
    required this.nomorTeleponKantor,
    required this.email,
    required this.status,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      nomorTelepon: json['nomor_telepon'] ?? '',
      nomorTeleponKantor: json['nomor_telepon_kantor'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
      'nomor_telepon_kantor': nomorTeleponKantor,
      'email': email,
      'status': status,
    };
  }
}
