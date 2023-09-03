import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/materials_bloc.dart'; // Sesuaikan dengan alamat file MaterialBloc
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/material.dart';

class FormMasterBahanScreen extends StatefulWidget {
  static const routeName = '/form_master_bahan_screen';

  const FormMasterBahanScreen({super.key});

  @override
  State<FormMasterBahanScreen> createState() =>
      _FormMasterBahanScreenState();
}

class _FormMasterBahanScreenState extends State<FormMasterBahanScreen> {
  String selectedKategori = "Bahan Baku";
  String selectedSatuan = "Kg";
  String selectedStatus = "Aktif";

  final TextEditingController namaBahanController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final MaterialBloc _materialBloc = MaterialBloc(); // Tambahkan ini di dalam widget class

  @override
  void dispose() {
    _materialBloc.close();
    super.dispose();
  }

void _addMaterial() {
  final Bahan newMaterial = Bahan(
    jenisBahan: selectedKategori, // jenis bahan diambil dari controller namaBahanController
    keterangan: keteranganController.text, //keternangan diambil dari controller keteranganController
    nama: namaBahanController.text, // nama bahan diambil dari controller namaBahanController
    satuan: selectedSatuan, // satuan diambil dari selectedSatuan
    status: selectedStatus == 'Aktif' ? 1 : 0, // status diambil dari selectedStatus
    stok: int.parse(stokController.text), // stok diambil dari controller stokController
  );

  final AddMaterialEvent addEvent = AddMaterialEvent(newMaterial);
  _materialBloc.add(addEvent);

  _showSuccessMessageAndNavigateBack();
}


  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan material.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 24.0),
                    const Text(
                      'Bahan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Nama Bahan',
                  placeholder: 'Nama',
                  controller: namaBahanController,
                ),
                const SizedBox(height: 16.0),
               DropdownWidget(
                  label: 'Satuan',
                  selectedValue: selectedKategori, // Isi dengan nilai yang sesuai
                  items: ['Bahan Baku', 'Bahan Tambahan'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedKategori = newValue; // Update _selectedValue saat nilai berubah
                      print('Selected value: $newValue');
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownWidget(
                        label: 'Satuan',
                        selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                        items: ['Kg', 'Ons', 'Pcs', 'Gram', 'Sak'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                ),
                const SizedBox(height: 16.0),
                TextFieldWidget(
                        label: 'Stok',
                        placeholder: 'Stok',
                        controller: stokController,
                ),
                const SizedBox(height: 16,),
                DropdownWidget(
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
                const SizedBox(height: 16),
                TextFieldWidget(
                  label: 'Keterangan',
                  placeholder: 'Keterangan',
                  controller: keteranganController,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          _addMaterial(); // Panggil method _addMaterial saat tombol "Simpan" ditekan
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
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle clear button press
                          namaBahanController.clear();
                          hargaController.clear();
                          stokController.clear();
                          keteranganController.clear();
                          selectedKategori = "Bahan Baku";
                          selectedSatuan = "Kg";
                          selectedStatus = "Aktif";
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
