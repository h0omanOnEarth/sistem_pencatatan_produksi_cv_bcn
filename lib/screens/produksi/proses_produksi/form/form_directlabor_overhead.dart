import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPencatatanDirectLaborScreen extends StatefulWidget {
  static const routeName = '/form_pencatatan_DLOC_screen';

  const FormPencatatanDirectLaborScreen({super.key});
  
  @override
  State<FormPencatatanDirectLaborScreen> createState() =>
      _FormPencatatanDirectLaborScreenState();
}

class _FormPencatatanDirectLaborScreenState extends State<FormPencatatanDirectLaborScreen> {
  DateTime? _selectedDate;
  String selectedPenggunaanBahan = "Penggunaan 1";

  @override
  Widget build(BuildContext context) {

    var nomorPerintahProduksiController;
    var namaBatchController;
    var upahTenagaKerjaPerJamController;
    var jumlahTenagaKerjaController;
    var jumlahJamTenagaKerjaController;
    var biayaOverheadController;
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
                    const SizedBox(width: 24.0),
                    const Flexible(
                      child: Text(
                        'Direct Labor and Overhead Cost',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                DatePickerButton(
                      label: 'Tanggal Pencatatan',
                      selectedDate: _selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                  ),
                const SizedBox(height: 16.0),
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
                    const SizedBox(width: 16.0),
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
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jumlah Tenaga Kerja',
                        placeholder: 'Jumlah Tenaga Kerja',
                        controller: jumlahTenagaKerjaController,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jum. Jam Tenaga Kerja',
                        placeholder: 'Jum. Jam Tenaga Kerja',
                        controller: jumlahJamTenagaKerjaController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Upah Tenaga Kerja /Jam',
                        placeholder: 'Upah /jam',
                        controller: upahTenagaKerjaPerJamController,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    const Expanded(
                      child: TextFieldWidget(
                        label: 'Biaya Tenaga Kerja',
                        placeholder: 'Biaya Tenaga Kerja',
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                    label: 'Biaya Overhead',
                    placeholder: 'Biaya Overhead',
                    controller: biayaOverheadController,
                ),
                const SizedBox(height: 16.0,),
                const TextFieldWidget(
                    label: 'Total Biaya',
                    placeholder: 'Total Biaya',
                    isEnabled: false,
                ),
                const SizedBox(height: 16.0,),
                const TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
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
                          backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
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
