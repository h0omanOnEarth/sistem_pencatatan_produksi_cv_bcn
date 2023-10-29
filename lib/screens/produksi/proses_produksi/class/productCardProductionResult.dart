import 'package:flutter/material.dart';

class ProductCardDataProductionResult {
  String nomorHasilProduksi;
  String kodeBarang;
  String namaBarang;
  String jumlahHasil;
  String satuan;
  String jumlahKonfirmasi;
  String selectedDropdownValue = '';
  TextEditingController?
      jumlahController; // Ubah tipe data menjadi TextEditingController?

  ProductCardDataProductionResult({
    required this.nomorHasilProduksi,
    required this.kodeBarang,
    required this.namaBarang,
    required this.jumlahHasil,
    required this.satuan,
    required this.jumlahKonfirmasi,
    this.selectedDropdownValue = '',
  }) {
    // Initialize the controller with the current 'jumlah' value
    jumlahController = TextEditingController(text: jumlahKonfirmasi);
  }
}
