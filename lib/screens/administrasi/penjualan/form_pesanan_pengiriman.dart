import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardData {
  String kodeProduk;
  String namaProduk;
  String jumlah;
  String satuan;
  String hargaSatuan;
  String subtotal;
  String selectedDropdownValue = '';

  ProductCardData({
    required this.kodeProduk,
    required this.namaProduk,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    required this.subtotal,
    this.selectedDropdownValue = '',
  });
}

class FormPesananPengirimanScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pengiriman_screen';

  const FormPesananPengirimanScreen({super.key});
  
  @override
  State<FormPesananPengirimanScreen> createState() =>
      _FormPesananPengirimanScreenState();
}

class _FormPesananPengirimanScreenState extends State<FormPesananPengirimanScreen> {
  DateTime? _selectedDate;
  String selectedPesanan = "Pesanan 1";
  String selectedMetode = "Pengiriman Truk Pabrik";
  
  var statusController;
  var pelangganController;
  var alamatController;
  var totalBarangController;
  var totalHargaController;
  var catatanController;
  var statusPembayaranController;
  
 List<ProductCardData> productCards = [];

  void addProductCard() {
    setState(() {
      productCards.add(ProductCardData(
        kodeProduk: '',
        namaProduk: '',
        jumlah: '',
        satuan: '',
        hargaSatuan: '',
        subtotal: '',
      ));
    });
  }

Widget buildProductCard(ProductCardData productCardData) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownDetailWidget(
              label: 'Kode Produk',
              items: ['Kode 1', 'Kode 2'],
              selectedValue: productCardData.kodeProduk,
              onChanged: (newValue) {
                setState(() {
                  productCardData.kodeProduk = newValue;
                });
              },
            ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Nama Produk',
              placeholder: 'Nama Produk',
              controller: TextEditingController(text: productCardData.namaProduk),
            ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Jumlah',
              placeholder: 'Jumlah',
              controller: TextEditingController(text: productCardData.jumlah),
            ),
              const SizedBox(height: 8.0),
             DropdownDetailWidget(
            label: 'Satuan',
            items: ['Satuan 1', 'Satuan 2'],
            selectedValue: productCardData.satuan,
            onChanged: (newValue) {
              setState(() {
                productCardData.satuan = newValue;
              });
            },
          ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
                label: 'Harga Satuan',
                placeholder: 'Harga Satuan',
                controller: TextEditingController(text: productCardData.hargaSatuan),
              ),
              const SizedBox(height: 8.0),
             TextFieldWidget(
                label: 'Subtotal',
                placeholder: 'Subtotal',
                controller: TextEditingController(text: productCardData.subtotal),
                isEnabled: false,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), // Add the desired margin
          child: Container(
            width: double.infinity, // Make the button full width
            child: ElevatedButton(
              onPressed: () {
                // Handle delete button press
                setState(() {
                  productCards.remove(productCardData);
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(10), // Add padding to the button
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Hapus',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@override
void initState() {
  super.initState();
  addProductCard(); // Tambahkan product card secara default pada initState
}

@override
Widget build(BuildContext context) {


  var waktuPengirimanController;
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
                    'Pesanan Pengiriman',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Di dalam widget buildProductCard atau tempat lainnya
              DropdownWidget(
                      label: 'Nomor Pesanan Pelanggan',
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
              DatePickerButton(
                label: 'Tanggal Pesanan Pengiriman',
                selectedDate: _selectedDate,
                onDateSelected: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFieldWidget(
                label: 'Pelanggan',
                placeholder: 'Pelanggan',
                controller: pelangganController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Alamat',
                placeholder: 'Alamat',
                controller: alamatController,
                multiline: true,
              ),
              const SizedBox(height: 16.0,),
               DropdownWidget(
                label: 'Metode Pengiriman',
                selectedValue: selectedMetode, // Isi dengan nilai yang sesuai
                items: ['Pengiriman Truk Pabrik'],
                onChanged: (newValue) {
                  setState(() {
                    selectedMetode = newValue; // Update _selectedValue saat nilai berubah
                    print('Selected value: $newValue');
                  });
                },
              ),
              const SizedBox(height: 16.0,),
                Row(
                children: [
                  Expanded(child: TextFieldWidget(
                      label: 'Total Barang',
                      placeholder: 'Total Barang',
                      controller: totalBarangController,
                      isEnabled: false,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  const Expanded(child: TextFieldWidget(
                      label: 'Satuan',
                      placeholder: 'Pcs',
                      isController: false,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                      label: 'Total Harga',
                      placeholder: 'Total Harga',
                      controller: totalHargaController,
                      isEnabled: false,
              ),
               const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Catatan',
                placeholder: 'Catatan',
                controller: catatanController,
              ),
              const SizedBox(height: 16.0,),
                 TextFieldWidget(
                label: 'Status Pembayaran',
                placeholder: 'Belum Bayar',
                controller: statusPembayaranController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
               Row(
                children: [
                  Expanded(child: TextFieldWidget(
                      label: 'Estimasi Waktu Pengiriman',
                      placeholder: 'Waktu Pengiriman',
                      controller: waktuPengirimanController,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  const Expanded(child: TextFieldWidget(
                      label: '',
                      placeholder: 'Days',
                      isController: false,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 16.0,),
               TextFieldWidget(
                label: 'Status',
                placeholder: 'In Process',
                controller: statusController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
              // Add Product Card Section
              const Text(
                'Detail Pesanan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  addProductCard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Tambah',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (productCards.isNotEmpty)
                ...productCards.map((productCardData) {
                  return buildProductCard(productCardData);
                }).toList(),
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

