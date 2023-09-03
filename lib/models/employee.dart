class Employee {
  final String id;
  final String alamat;
  final String email;
  final int gajiHarian;
  final int gajiLemburJam;
  final String jenisKelamin;
  final String nomorTelepon;
  final String nama;
  final String password;
  final String posisi;
  final int status;
  final DateTime tanggalMasuk;
  final String username;

  Employee({
    required this.id,
    required this.email,
    required this.password,
    required this.alamat,
    required this.gajiHarian,
    required this.gajiLemburJam,
    required this.jenisKelamin,
    required this.nama,
    required this.nomorTelepon,
    required this.posisi,
    required this.status,
    required this.tanggalMasuk,
    required this.username,
  });

  // Metode untuk mengonversi objek Employee menjadi map JSON
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'alamat': alamat,
      'email': email,
      'gajiHarian': gajiHarian,
      'gajiLemburJam': gajiLemburJam,
      'jenisKelamin': jenisKelamin,
      'nomorTelepon': nomorTelepon,
      'nama': nama,
      'password': password,
      'posisi': posisi,
      'status': status,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'username': username,
    };
  }
}
