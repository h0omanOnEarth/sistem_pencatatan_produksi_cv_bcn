class Employee {
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
}
