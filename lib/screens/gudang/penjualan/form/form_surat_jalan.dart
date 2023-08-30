import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_withField_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormSuratJalanScreen extends StatefulWidget {
  static const routeName = '/form_surat_jalan_screen';

  const FormSuratJalanScreen({super.key});
  
  @override
  State<FormSuratJalanScreen> createState() =>
      _FormSuratJalanScreenState();
}

class _FormSuratJalanScreenState extends State<FormSuratJalanScreen> {
  DateTime? _selectedDate;
  String selectedNomorPerintahPengiriman = 'Perintah 1';
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController jumlahDusController= TextEditingController();
  
  var catatanController;
  var namaPelangganController;
  var totalHargaController;
  var totalProdukController;
  var statusController;
  var nomorPesananPelanggan;
  var kodePelangganController;

@override
Widget build(BuildContext context) {
 
  var nomorSuratJalanController;
  var KodePenerimaController;
  var namaPenerimaController;
  var alamatController;
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
                        'Surat Jalan',
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
              TextFieldWidget(
                  label: 'Nomor Surat Jalan',
                  placeholder: 'Nomor Surat Jalan',
                  controller: nomorSuratJalanController,
                  isEnabled: false,
                ),
             const SizedBox(height: 16.0,),
             DatePickerButton(
                        label: 'Tanggal Pembuatan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Perintah Pengiriman',
                      selectedValue: selectedNomorPerintahPengiriman, // Isi dengan nilai yang sesuai
                      items: ['Perintah 1', 'Perintah 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNomorPerintahPengiriman = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child:  
                  TextFieldWidget(
                      label: 'Penerima',
                      placeholder: 'Penerima',
                      controller: KodePenerimaController,
                      isEnabled: false,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Penerima',
                      placeholder: 'Nama Penerima',
                      controller: namaPenerimaController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               TextFieldWidget(
                label: 'Alamat Penerima',
                placeholder: 'Alamat',
                controller: alamatController,
                multiline: true,
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Total Produk',
                placeholder: 'Total Produk',
                controller: totalProdukController,
                isEnabled: false,
              ),
               const SizedBox(height: 16),
               TextFieldWidget(
                label: 'Status',
                placeholder: 'Dalam Proses',
                controller: statusController,
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
                CustomWithTextFieldCard(
                content: [
                  CustomWithTextFieldCardContent(text: 'Kode Barang: B001'),
                  CustomWithTextFieldCardContent(text: 'Nama Barang: Gelas Pop 22 oz'),
                  CustomWithTextFieldCardContent(text: 'Jumlah: 100.000 pcs'),
                  CustomWithTextFieldCardContent(text: 'Total: 50 dus'),
                  CustomWithTextFieldCardContent(text: 'Jumlah Pengiriman (Pcs):', isBold: true),
                  CustomWithTextFieldCardContent(
                    text: '',
                    isRow: true,
                    leftHintText: 'Jumlah',
                    rightHintText: 'Pcs',
                    rightEnabled: false, // Disable the left TextField
                    controller: jumlahController
                  ),
                  CustomWithTextFieldCardContent(text: 'Jumlah Pengiriman (Dus):', isBold: true),
                  CustomWithTextFieldCardContent(
                    text: '',
                    isRow: true,
                    leftHintText: 'Jumlah',
                    rightHintText: 'Dus',
                    rightEnabled: false, // Disable the left TextField
                    controller: jumlahDusController
                  ),
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

