import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPemindahanBahan extends StatefulWidget {
  static const routeName = '/form_pemindahan_bahan_screen';

  const FormPemindahanBahan({super.key});
  
  @override
  State<FormPemindahanBahan> createState() =>
      _FormPemindahanBahanState();
}

class _FormPemindahanBahanState extends State<FormPemindahanBahan> {
  DateTime? _selectedDate;
  String selectedNomorPermintaan = 'Permintaan 1';
  
@override
Widget build(BuildContext context) {
 
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
                  const SizedBox(width: 16.0),
                  const Flexible(
                        child: Text(
                          'Pemindahan Bahan',
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
                        label: 'Tanggal Pemindahan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Permintaan Bahan',
                      selectedValue: selectedNomorPermintaan, // Isi dengan nilai yang sesuai
                      items: ['Permintaan 1', 'Permintaan 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNomorPermintaan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
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
              const Text(
                'Detail Pemindahan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              CustomCard(
              content: [
                CustomCardContent(text: 'Kode Bahan : B001'),
                CustomCardContent(text: 'Nama Bahan : Biji Plastik'),
                CustomCardContent(text: 'Stok : 1.000 kg'),
                CustomCardContent(text: 'Jumlah : 1.000 kg'),
              ],
            ),
            CustomCard(
              content: [
                CustomCardContent(text: 'Kode Bahan : B001'),
                CustomCardContent(text: 'Nama Bahan : Biji Plastik'),
                CustomCardContent(text: 'Stok : 1.000 kg'),
                CustomCardContent(text: 'Jumlah : 1.000 kg'),
              ],
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

