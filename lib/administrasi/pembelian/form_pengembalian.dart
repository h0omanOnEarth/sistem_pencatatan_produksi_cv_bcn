import 'package:flutter/material.dart';

import '../../widgets/date_picker_button.dart';
import '../../widgets/general_drop_down.dart';
import '../../widgets/text_field_widget.dart';

class FormPengembalianPesananScreen extends StatefulWidget {
  static const routeName = '/form_pengembalian_pesanan_pembelian_screen';

  const FormPengembalianPesananScreen({super.key});
  
  @override
  State<FormPengembalianPesananScreen> createState() =>
      _FormPengembalianPesananScreenState();
}

class _FormPengembalianPesananScreenState extends State<FormPengembalianPesananScreen> {
  DateTime? _selectedDate;
  String selectedPesanan = "Pesanan 1";
  String _selectedSatuan = "Kg";
  String _selectedStatus = "Aktif";
  
  @override
  Widget build(BuildContext context) {
    var tanggalPemesananController;
    var kodeBahanController;
    var namaBahanController;
    var supplierController;
    var alamatPengembalianController;

    var jumlahController;
    var alasanController;
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
                        child:const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                   const SizedBox(width: 16.0),
                    const Text(
                      'Pengembalian Pesanan Pembelian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                DropdownWidget(
                label: 'Nomor Pesanan',
                selectedValue: selectedPesanan, // Isi dengan nilai yang sesuai
                items: ['Pesanan 1', 'Pesanan 2'],
                onChanged: (newValue) {
                  setState(() {
                    selectedPesanan = newValue; // Update _selectedValue saat nilai berubah
                    print('Selected value: $newValue');
                  });
                },
              ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Tanggal Pemesanan',
                  placeholder: 'Tanggal Pemesanan',
                  controller: tanggalPemesananController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Kode Bahan',
                        placeholder: 'Kode Bahan',
                        controller: kodeBahanController,
                        isEnabled: false,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Nama Bahan',
                        placeholder: 'Nama Bahan',
                        controller: namaBahanController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFieldWidget(
                  label: 'Nama Supplier',
                  placeholder: 'Nama Supplier',
                  controller: supplierController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                    label: 'Alamat Pengembalian',
                    placeholder: 'Alamat Pengembalian',
                    controller: alamatPengembalianController,
                    multiline: true,
                  ),
                const SizedBox(height: 16.0,),
                DatePickerButton(
                        label: 'Tanggal Pengembalian',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                ), 
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jumlah',
                        placeholder: 'Jumlah',
                        controller: jumlahController,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:  DropdownWidget(
                      label: 'Satuan',
                      selectedValue: _selectedSatuan, // Isi dengan nilai yang sesuai
                      items: ['Kg','Ons','Pcs','Gram','Sak'],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                      
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                 DropdownWidget(
                      label: 'Status',
                      selectedValue: _selectedStatus, // Isi dengan nilai yang sesuai
                      items: ['Aktif', 'Tidak Aktif'],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                const SizedBox(height: 16.0,),
                  TextFieldWidget(
                  label: 'Alasan',
                  placeholder: 'Alasan',
                  controller: alasanController,
                  multiline: true,
                ),
                const SizedBox(height: 16.0,),
                  TextFieldWidget(
                  label: 'Cataan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                ),
                const SizedBox(height: 16.0,),
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
                          padding:  EdgeInsets.symmetric(vertical: 16.0),
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
