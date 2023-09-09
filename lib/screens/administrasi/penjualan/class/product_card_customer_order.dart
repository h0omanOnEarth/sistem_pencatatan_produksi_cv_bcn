// product_card_data.dart

import 'package:flutter/material.dart';

class ProductCardDataCustomerOrder {
  String kodeProduk;
  String namaProduk;
  String jumlah;
  String satuan;
  String hargaSatuan;
  String subtotal;
  String selectedDropdownValue = '';
  TextEditingController? jumlahController; // Ubah tipe data menjadi TextEditingController?
  TextEditingController? hargaSatuanController; // Ubah tipe data menjadi TextEditingController?

  ProductCardDataCustomerOrder({
    required this.kodeProduk,
    required this.namaProduk,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    required this.subtotal,
    this.selectedDropdownValue = '',
  }) {
    // Initialize the controller with the current 'jumlah' value
    jumlahController = TextEditingController(text: jumlah);
    hargaSatuanController = TextEditingController(text: hargaSatuan);
  }

  void calculateSubtotal() {
    if (jumlah.isNotEmpty && hargaSatuan.isNotEmpty) {
      int jumlahValue = int.tryParse(jumlah) ?? 0;
      int hargaSatuanValue = int.tryParse(hargaSatuan) ?? 0;
      int result = jumlahValue * hargaSatuanValue;
      subtotal = result.toString().replaceAll(RegExp(r'^0+(?=\d)'), ''); // Format sebagai string dengan 2 desimal dan hapus nol di depan
    } else {
      subtotal = ''; // Atur subtotal menjadi kosong jika jumlah atau harga satuan kosong
    }
  }
}
