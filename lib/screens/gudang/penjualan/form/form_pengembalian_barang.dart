import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/customer_order_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_withField_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPengembalianBarangScreen extends StatefulWidget {
  static const routeName = '/form_pengembalian_barang_screen';
  final String? invoiceId;
  final String? custOrderReturnId;

  const FormPengembalianBarangScreen({Key? key, this.invoiceId, this.custOrderReturnId}) : super(key: key);
  
  @override
  State<FormPengembalianBarangScreen> createState() =>
      _FormPengembalianBarangScreenState();
}

class _FormPengembalianBarangScreenState extends State<FormPengembalianBarangScreen> {
  DateTime? _selectedDate;
  String selectedNomorFaktur = 'Faktur 1';

  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nomorPesananPelanggan = TextEditingController();
  TextEditingController kodePelangganController =TextEditingController();
  TextEditingController alasanPengembalianController = TextEditingController();

@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => CustomerOrderReturnBloc(),
    child: Scaffold(
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
                        'Pengembalian Barang',
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
                        label: 'Tanggal Pengembalian',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                      label: 'Nomor Faktur',
                      selectedValue: selectedNomorFaktur, // Isi dengan nilai yang sesuai
                      items: ['Faktur 1', 'Faktur 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedNomorFaktur = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
              ),
              const SizedBox(height: 16.0,),
             const TextFieldWidget(
              label: 'Nomor Surat Jalan',
              placeholder: 'Nomor Surat Jalan',
              isEnabled: false,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child:  
                  TextFieldWidget(
                      label: 'Kode Pelanggan',
                      placeholder: 'Kode Pelanggan',
                      controller: kodePelangganController,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Pelanggan',
                      placeholder: 'Nama Pelanggan',
                      controller: namaPelangganController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               TextFieldWidget(
                label: 'Alasan Pengembalian',
                placeholder: 'Alasan',
                controller: alasanPengembalianController,
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
                        backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
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
  )
  );
}
}

