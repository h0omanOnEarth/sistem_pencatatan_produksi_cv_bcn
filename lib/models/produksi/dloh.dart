import 'package:cloud_firestore/cloud_firestore.dart';

class DLOH {
  String id;
  String materialUsageId;
  String catatan;
  String status;
  int jumlahTenagaKerja;
  int jumlahJamTenagaKerja;
  int biayaTenagaKerja;
  int biayaOverhead;
  int upahTenagaKerjaPerjam;
  int subtotal;
  DateTime tanggalPencatatan;

  DLOH({
    required this.id,
    required this.materialUsageId,
    required this.catatan,
    this.status="",
    this.jumlahTenagaKerja = 0,
    this.jumlahJamTenagaKerja = 0,
    this.biayaTenagaKerja = 0,
    this.biayaOverhead = 0,
    this.upahTenagaKerjaPerjam = 0,
    this.subtotal = 0,
    required this.tanggalPencatatan,
  });

  // Factory constructor untuk membuat instance DLOH dari Map
  factory DLOH.fromMap(Map<String, dynamic> map) {
    return DLOH(
      id: map['id'] as String,
      materialUsageId: map['material_usage_id'] as String,
      catatan: map['catatan'] as String,
      status: map['status'] as String,
      jumlahTenagaKerja: map['jumlah_tenaga_kerja'] as int,
      jumlahJamTenagaKerja: map['jumlah_jam_tenaga_kerja'] as int,
      biayaTenagaKerja: map['biaya_tenaga_kerja'] as int,
      biayaOverhead: map['biaya_overhead'] as int,
      upahTenagaKerjaPerjam: map['upah_tenaga_kerja_perjam'] as int,
      subtotal: map['subtotal'] as int,
      tanggalPencatatan: (map['tanggal_pencatatan'] as Timestamp).toDate(),
    );
  }

  // Mengonversi instance DLOH ke dalam Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'material_usage_id': materialUsageId,
      'catatan': catatan,
      'status': status,
      'jumlah_tenaga_kerja': jumlahTenagaKerja,
      'jumlah_jam_tenaga_kerja': jumlahJamTenagaKerja,
      'biaya_tenaga_kerja': biayaTenagaKerja,
      'biaya_overhead': biayaOverhead,
      'upah_tenaga_kerja_perjam': upahTenagaKerjaPerjam,
      'subtotal': subtotal,
      'tanggal_pencatatan': tanggalPencatatan,
    };
  }
}
