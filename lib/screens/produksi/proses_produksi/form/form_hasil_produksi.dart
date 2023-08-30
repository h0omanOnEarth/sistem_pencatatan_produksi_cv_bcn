import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormHasilProduksiScreen extends StatefulWidget {
  static const routeName = '/form_pencatatan_hasil_produksi_screen';

  const FormHasilProduksiScreen({super.key});
  
  @override
  State<FormHasilProduksiScreen> createState() =>
      _FormHasilProduksiScreenState();
}

class _FormHasilProduksiScreenState extends State<FormHasilProduksiScreen> {
  DateTime? _selectedDate;
  String selectedPenggunaanBahan = "Penggunaan 1";
  String selectedSatuan = "Kg";

  @override
  Widget build(BuildContext context) {

    var nomorPerintahProduksiController;
    var namaBatchController;
    var catatanController;
    var jumlahProdukCacatController;
    var jumlahProdukBerhasilController;
    var waktuProduksiController;
    var jumlahProdukController;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.0),
                    const Flexible(
                      child: Text(
                        'Hasil Produksi',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                DatePickerButton(
                      label: 'Tanggal Pencatatan',
                      selectedDate: _selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                  ),
                SizedBox(height: 16.0),
                DropdownWidget(
                        label: 'Nomor Penggunaan Bahan',
                        selectedValue: selectedPenggunaanBahan, // Isi dengan nilai yang sesuai
                        items: ['Penggunaan 1', 'Penggunaan 2'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedPenggunaanBahan = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Nomor Perintah Produksi',
                        placeholder: 'Nomor Perintah Produksi',
                        controller: nomorPerintahProduksiController,
                        isEnabled: false,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Batch',
                        placeholder: 'Batch',
                        controller: namaBatchController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                  Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jumlah Produk',
                        placeholder: 'Jumlah Produk',
                        controller: jumlahProdukController,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: 
                      DropdownWidget(
                        label: 'Satuan',
                        selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                        items: ['Pcs', 'Kg', 'Ons'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Produk Cacat',
                  placeholder: 'Jumlah Produk Cacat',
                  controller: jumlahProdukCacatController,
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Produk Berhasil',
                  placeholder: 'Jumlah Produk Berhasil',
                  controller: jumlahProdukBerhasilController,
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                    label: 'Waktu Produksi',
                    placeholder: 'Waktu Produksi',
                    controller: waktuProduksiController,
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  isEnabled: false,
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Simpan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle clear button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Bersihkan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
