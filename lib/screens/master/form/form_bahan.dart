import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterBahanScreen extends StatefulWidget {
  static const routeName = '/form_master_bahan_screen';

  const FormMasterBahanScreen({super.key});
  
  @override
  State<FormMasterBahanScreen> createState() =>
      _FormMasterBahanScreenState();
}

class _FormMasterBahanScreenState extends State<FormMasterBahanScreen> {
  String selectedSupplier = "Supplier 1";
  String selectedKategori = "Kategori 1";
  String selectedSatuan = "Kg";
  String selectedStatus = "Aktif";

  @override
  Widget build(BuildContext context) {
    var namaBahanController;
    var hargaController;
    var stokController;
    var keteranganController;
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
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.0),
                    Text(
                      'Bahan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                  TextFieldWidget(
                  label: 'Nama Bahan',
                  placeholder: 'Naman',
                  controller: namaBahanController,
                ),
                SizedBox(height: 16.0),
                DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedSupplier, // Isi dengan nilai yang sesuai
                      items: ['Supplier 1', 'Supplier 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSupplier = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Harga',
                  placeholder: 'Harga',
                  controller: hargaController,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedKategori, // Isi dengan nilai yang sesuai
                      items: ['Kategori 1', 'Kategori 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedKategori = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                      items: ['Kg','Ons','Pcs','Gram','Sak'],
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
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(child: TextFieldWidget(
                        label: 'Stok',
                        placeholder: 'Stok',
                        controller: stokController,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Status',
                      selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                      items: ['Aktif', 'Tidak Aktif'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFieldWidget(
                  label: 'Keterangan',
                  placeholder: 'Keterangan',
                  controller: keteranganController,
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
                        child: Padding(
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
                        child: Padding(
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
