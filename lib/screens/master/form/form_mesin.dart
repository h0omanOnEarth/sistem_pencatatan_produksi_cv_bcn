import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/form_master_mesin_screen';

  const FormMasterMesinScreen({super.key});
  
  @override
  State<FormMasterMesinScreen> createState() =>
      _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String selectedTipe = "Penggiling";
  String selectedSupplier = "Supplier 1";
  String selectedKondisi = "Baru";
  String selectedStatus = "Aktif";
  String selectedSatuan = "Kg";

  @override
  Widget build(BuildContext context) {
    var namaController;
    var nomorSeriController;
    var kapasitasController;
    var tahunPembutanController;
    var tahunPerolehanController;
    var catatanController;
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
                    const Text(
                      'Mesin',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Nama Mesin',
                  placeholder: 'Nama',
                  controller: namaController,
                ),
                SizedBox(height: 16.0),
                DropdownWidget(
                      label: 'Tipe',
                      selectedValue: selectedTipe, // Isi dengan nilai yang sesuai
                      items: ['Penggiling', 'Pencampur', 'Pencetak'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedTipe = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Nomor Seri',
                  placeholder: 'Nomor Seri',
                  controller: nomorSeriController,
                ),
                SizedBox(height: 16.0,),
                 Row(
                  children: [
                    Expanded(
                      child: 
                        TextFieldWidget(
                        label: 'Kapasitas Produksi',
                        placeholder: 'Kapasitas Produksi',
                        controller: kapasitasController,
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
                SizedBox(height: 16.0,),
                 Row(
                  children: [
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Tahun Pembuatan',
                        placeholder: '20XX',
                        controller: tahunPembutanController,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Tahun Perolehan',
                        placeholder: '20XX',
                        controller: tahunPerolehanController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                DropdownWidget(
                      label: 'Supplier',
                      selectedValue: selectedSupplier, // Isi dengan nilai yang sesuai
                      items: ['Supplier 1', 'Supplier 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSupplier = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                  multiline: true,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
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
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                          label: 'Kondisi',
                          selectedValue: selectedKondisi, // Isi dengan nilai yang sesuai
                          items: ['Baru', 'Bekas'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedKondisi = newValue; // Update _selectedValue saat nilai berubah
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
