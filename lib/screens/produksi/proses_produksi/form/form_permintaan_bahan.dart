import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPermintaanBahanScreen extends StatefulWidget {
  static const routeName = '/form_permintaan_bahan_screen';

  const FormPermintaanBahanScreen({super.key});
  
  @override
  State<FormPermintaanBahanScreen> createState() =>
      _FormPermintaanBahanScreenState();
}

class _FormPermintaanBahanScreenState extends State<FormPermintaanBahanScreen> {
  DateTime? _selectedTanggalPermintaan;
  String selectedNoPerintah = 'Perintah 1';
  
@override
Widget build(BuildContext context) {
 
  var tanggalProduksiController;
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
                  const Text(
                    'Permintaan Bahan',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Di dalam widget buildProductCard atau tempat lainnya
             DatePickerButton(
                        label: 'Tanggal Permintaan',
                        selectedDate: _selectedTanggalPermintaan,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPermintaan = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Perintah Produksi',
                      selectedValue: selectedNoPerintah, // Isi dengan nilai yang sesuai
                      items: ['Perintah 1', 'Perintah 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNoPerintah = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Tanggal Produksi',
                placeholder: 'Tanggal Produksi',
                controller: tanggalProduksiController,
                isEnabled: false,
              ),
             const SizedBox(height: 16),
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
              const Text(
                'Detail Pesanan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              CustomCard(
                title: 'Kode Barang : B0001',
                content: [
                  'Nama Barang : Gelas Pop 22 oz',
                  'Jumlah : 100.000 pcs',
                  'Harga : Rp 40,00',
                  'Total Harga : Rp 4.000.000,00',
                ],
              ),
              CustomCard(
                title: 'Kode Barang : B0002',
                content: [
                  'Nama Barang : Sendok Plastik',
                  'Jumlah : 50.000 pcs',
                  'Harga : Rp 20,00',
                  'Total Harga : Rp 1.000.000,00',
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

