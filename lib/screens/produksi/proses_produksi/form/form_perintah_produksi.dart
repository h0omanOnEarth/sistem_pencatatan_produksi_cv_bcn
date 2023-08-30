import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPerintahProduksiScreen extends StatefulWidget {
  static const routeName = '/form_perintah_produksi_screen';

  const FormPerintahProduksiScreen({super.key});
  
  @override
  State<FormPerintahProduksiScreen> createState() =>
      _FormPerintahProduksiScreenState();
}

class _FormPerintahProduksiScreenState extends State<FormPerintahProduksiScreen> {
  DateTime? _selectedTanggalRencana;
  DateTime? _selectedTanggalProduksi;
  DateTime? _selectedTanggalSelesai;
  String selectedKodeProduk = 'Produk 1';
  String selectedKodeBOM = 'BOM 1';
  String selectedMesinMixer = 'Mixer 1';
  String selectedMesinSheet = 'Sheet 1';
  String selectedMesinCetak = 'Cetak 1';
  
@override
Widget build(BuildContext context) {
 
  var namaProdukController;
  var jumlahProduksiController;
  var perkiraanLamaWaktuController;
  var catatanController;
  var jumlahTenagaKerjaController;
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
                        'Perintah Produksi',
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
                        label: 'Tanggal Rencana',
                        selectedDate: _selectedTanggalRencana,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalRencana = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DatePickerButton(
                        label: 'Tanggal Produksi',
                        selectedDate: _selectedTanggalProduksi,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalProduksi = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DatePickerButton(
                        label: 'Tanggal Selesai',
                        selectedDate: _selectedTanggalSelesai,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalSelesai = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child:  DropdownWidget(
                      label: 'Kode Produk',
                      selectedValue: selectedKodeProduk, // Isi dengan nilai yang sesuai
                      items: ['Produk 1', 'Produk 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedKodeProduk = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Produk',
                      placeholder: 'Nama Produk',
                      controller: namaProdukController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownWidget(
                      label: 'Nomor Bill of Material',
                      selectedValue: selectedKodeBOM, // Isi dengan nilai yang sesuai
                      items: ['BOM 1', 'BOM 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedKodeBOM = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Jumlah Produksi (est)',
                      placeholder: '0',
                      controller: jumlahProduksiController,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Perkiraan Lama Waktu',
                      placeholder: '120m',
                      controller: perkiraanLamaWaktuController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                    label: 'Jumlah Tenaga Kerja (est)',
                    placeholder: 'Jumlah Tenaga Kerja',
                    controller: jumlahTenagaKerjaController,
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
               const Text(
                'Instruksi Produksi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              CustomCard(
                content: [
                  CustomCardContent(text: '1. Campur bahan recycle dan biji plastik PP.'),
                  CustomCardContent(text: '2. Ekstruksi dan Bentuk PP Sheet.'),
                  CustomCardContent(text: '3. Cetak PP Sheet menjadi gelas plastik'),
                  CustomCardContent(text: '4. Uji kualitas dan pengemasan'),
                ],
              ),
              const SizedBox(height: 16.0,),
              const Text(
                'Mesin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Mixer',
                      selectedValue: selectedMesinMixer, // Isi dengan nilai yang sesuai
                      items: ['Mixer 1', 'Mixer 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedMesinMixer = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                    label: 'Sheet',
                    selectedValue: selectedMesinSheet, // Isi dengan nilai yang sesuai
                    items: ['Sheet 1', 'Sheet 2'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedMesinSheet = newValue; // Update _selectedValue saat nilai berubah
                        print('Selected value: $newValue');
                      });
                    },
              ),
             const SizedBox(height: 16.0,),
            DropdownWidget(
                      label: 'Cetak',
                      selectedValue: selectedMesinCetak, // Isi dengan nilai yang sesuai
                      items: ['Cetak 1', 'Cetak 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedMesinCetak = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
               const Text(
                'Bahan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
               CustomCard(
                content: [
                  CustomCardContent(text: 'Nama Barang : Gelas Pop 22 oz'),
                  CustomCardContent(text: 'Jumlah : 100.000 pcs'),
                  CustomCardContent(text: 'Harga : Rp 40,00'),
                  CustomCardContent(text: 'Total Harga : Rp 4.000.000,00'),
                ],
              ),
               CustomCard(
                content: [
                  CustomCardContent(text: 'Nama Barang : Gelas Pop 22 oz'),
                  CustomCardContent(text: 'Jumlah : 100.000 pcs'),
                  CustomCardContent(text: 'Harga : Rp 40,00'),
                  CustomCardContent(text: 'Total Harga : Rp 4.000.000,00'),
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

