import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormFakturPenjualanScreen extends StatefulWidget {
  static const routeName = '/form_faktur_penjualan_screen';

  const FormFakturPenjualanScreen({super.key});
  
  @override
  State<FormFakturPenjualanScreen> createState() =>
      _FormFakturPenjualanScreenState();
}

class _FormFakturPenjualanScreenState extends State<FormFakturPenjualanScreen> {
  DateTime? _selectedDate;
  String selectedNomorSuratJalan = 'Surat Jalan 1';
  String selectedNomorRekening = 'Rekening 1';
  String selectedStatusPembayaran = 'Belum Bayar';
  
  var catatanController;
  var namaPelangganController;
  var totalHargaController;
  var totalProdukController;
  var statusController;
  var nomorPesananPelanggan;
  var kodePelangganController;

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
                  const SizedBox(width: 16.0),
                  const Flexible(
                      child: Text(
                        'Pesanan Penjualan',
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
                        label: 'Tanggal Faktur',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Surat Jalan',
                      selectedValue: selectedNomorSuratJalan, // Isi dengan nilai yang sesuai
                      items: ['Surat Jalan 1', 'Surat Jalan 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNomorSuratJalan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0),
               TextFieldWidget(
                  label: 'Nomor Pesanan',
                  placeholder: 'Nomor Pesanan',
                  controller: nomorPesananPelanggan,
                  isEnabled: false,
                ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(child:  
                  TextFieldWidget(
                      label: 'Kode Pelanggan',
                      placeholder: '-',
                      controller: kodePelangganController,
                      isEnabled: false,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Pelanggan',
                      placeholder: '-',
                      controller: namaPelangganController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               TextFieldWidget(
                label: 'Status',
                placeholder: 'Dalam Proses',
                controller: statusController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Total Harga',
                      placeholder: 'Total Harga',
                      controller: totalHargaController,
                      isEnabled: false,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Total Produk',
                      placeholder: 'Total Produk',
                      controller: totalProdukController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Rekening',
                      selectedValue: selectedNomorRekening, // Isi dengan nilai yang sesuai
                      items: ['Rekening 1', 'Rekening 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNomorRekening = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Status Pembayaran',
                      selectedValue: selectedStatusPembayaran, // Isi dengan nilai yang sesuai
                      items: ['Belum Bayar', 'Lunas'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatusPembayaran = newValue; // Update _selectedValue saat nilai berubah
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
              const Text(
                'Detail Pesanan',
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
