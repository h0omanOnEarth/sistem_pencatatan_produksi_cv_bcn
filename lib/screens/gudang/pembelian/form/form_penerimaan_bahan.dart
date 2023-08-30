import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenerimaanBahanScreen extends StatefulWidget {
  static const routeName = '/form_penerimaan_bahan_screen';

  const FormPenerimaanBahanScreen({super.key});
  
  @override
  State<FormPenerimaanBahanScreen> createState() =>
      _FormPenerimaanBahanScreenState();
}

class _FormPenerimaanBahanScreenState extends State<FormPenerimaanBahanScreen> {
  DateTime? _selectedDate;
  String selectedNomorPermintaan = "Permintaan 1";
  String selectedKodeBahan = "Bahan 1";
  String selectedSupplier = "Supplier 1";

  @override
  Widget build(BuildContext context) {
    var catatanController;
    var jumlahDiterimaController;
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
                        'Penerimaan Bahan',
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
                      label: 'Tanggal Penerimaan',
                      selectedDate: _selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                  ),
                SizedBox(height: 16.0),
                DropdownWidget(
                        label: 'Nomor Permintaan Pembelian Bahan',
                        selectedValue: selectedNomorPermintaan, // Isi dengan nilai yang sesuai
                        items: ['Permintaan 1', 'Permintaan 2', 'Permintaan 3'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedNomorPermintaan = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child:  DropdownWidget(
                        label: 'Kode Supplier',
                        selectedValue: selectedSupplier, // Isi dengan nilai yang sesuai
                        items: ['Supplier 1', 'Supplier 2', 'Supplier 3'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedSupplier = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Nama Supplier',
                        placeholder: 'Nama Supplier',
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child:  DropdownWidget(
                        label: 'Kode Bahan',
                        selectedValue: selectedKodeBahan, // Isi dengan nilai yang sesuai
                        items: ['Bahan 1', 'Bahan 2', 'Bahan 3'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedKodeBahan = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Nama Bahan',
                        placeholder: 'Nama Bahan',
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
                        label: 'Jumlah Permintaan',
                        placeholder: 'Jumlah Permintaan',
                        isEnabled: false,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: 
                     TextFieldWidget(
                        label: 'Satuan',
                        placeholder: 'Kg',
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Diterima',
                  placeholder: 'Jumlah Diterima',
                  controller: jumlahDiterimaController,
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
