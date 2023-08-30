import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPengubahanBahan extends StatefulWidget {
  static const routeName = '/form_pengubahan_bahan_screen';

  const FormPengubahanBahan({super.key});
  
  @override
  State<FormPengubahanBahan> createState() =>
      _FormPengubahanBahanState();
}

class _FormPengubahanBahanState extends State<FormPengubahanBahan> {
  DateTime? _selectedDate;
  String selectedKodeMesin = 'Mesin 1';
  
@override
Widget build(BuildContext context) {
 
  var catatanController;
  var jumlahController;
  var jumlahHasilController;
  var totalPengubahanController;
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
                  const SizedBox(width: 16.0),
                  const Flexible(
                        child: Text(
                          'Pengubahan Bahan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Di dalam widget buildProductCard atau tempat lainnya
             DatePickerButton(
                        label: 'Tanggal Pengubahan',
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
                  Expanded(child:  
                    DropdownWidget(
                          label: 'Kode Mesin',
                          selectedValue: selectedKodeMesin, // Isi dengan nilai yang sesuai
                          items: ['Mesin 1', 'Mesin 2'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedKodeMesin = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                  ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Mesin',
                      placeholder: 'Nama Mesin',
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Jumlah Barang Gagal (Pcs)',
                placeholder: 'Jumlah Barang Gagal',
                controller: jumlahController,
              ),
              const SizedBox(height: 16.0,),
               Row(
                children: [
                  Expanded(child:  
                   TextFieldWidget(
                      label: 'Jumlah Hasil Pengubahan',
                      placeholder: 'Jumlah Mesin',
                      controller: jumlahHasilController,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Satuan',
                      placeholder: 'Kg',
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
               Row(
                children: [
                  Expanded(child:  
                   TextFieldWidget(
                      label: 'Total Pengubahan',
                      placeholder: 'Total Mesin',
                      controller: totalPengubahanController,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Satuan',
                      placeholder: 'Kg',
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Catatan',
                placeholder: 'Catatan',
                controller: catatanController,
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Status',
                placeholder: 'Dalam Proses',
                isEnabled: false,
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

