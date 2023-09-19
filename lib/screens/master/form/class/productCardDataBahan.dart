import 'package:flutter/material.dart';

class ProductCardDataBahan {
  String kodeBahan;
  String namaBahan;
  String? namaBatch;
  String jumlah;
  String satuan;
  String selectedDropdownValue = '';
  TextEditingController? jumlahController; // Ubah tipe data menjadi TextEditingController?

  ProductCardDataBahan({
   required this.kodeBahan,
    required this.namaBahan,
    this.namaBatch,
    required this.jumlah,
    required this.satuan,
    this.selectedDropdownValue = '',
  }) {
    // Initialize the controller with the current 'jumlah' value
    jumlahController = TextEditingController(text: jumlah);
  }
  
}
