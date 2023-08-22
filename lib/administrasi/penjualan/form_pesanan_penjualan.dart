import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

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

class FormPesananPelangganScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pelanggan_screen';

  const FormPesananPelangganScreen({super.key});
  
  @override
  State<FormPesananPelangganScreen> createState() =>
      _FormPesananPelangganScreenState();
}

class _FormPesananPelangganScreenState extends State<FormPesananPelangganScreen> {
  DateTime? _selectedTanggalPesan;
  DateTime? _selectedTanggalKirim;
  String? selectedKode;

Future<void> _selectDate(BuildContext context, String label) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (pickedDate != null && pickedDate != _selectedTanggalPesan && pickedDate !=_selectedTanggalKirim) {
    print("Picked Date: $pickedDate"); // Check if pickedDate is correct
    setState(() {
      if(label=='Tanggal Pesan'){
        _selectedTanggalPesan = pickedDate;
        print("_selectedDate: $_selectedTanggalPesan"); // Check if _selectedDate is updated
      }else if(label== 'Tanggal Kirim'){
        _selectedTanggalKirim = pickedDate;
        print("_selectedDate: $_selectedTanggalKirim"); // Check if _selectedDate is updated
      }
    });
  }
}

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

  Widget buildTextField(String label, String placeholder,
    {bool multiline = false, bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.0),
        TextField(
          maxLines: multiline ? 3 : 1,
          enabled: isEnabled,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey[300], // Change background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            hintStyle: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

 Widget buildDropdown(String label, List<String> items) {
  List<String> uniqueItems = items.toSet().toList(); // Remove duplicates
  String? selectedValue;

  if (label == 'Kode Pelanggan') {
    selectedValue = selectedKode;
  } 

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: 8.0),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          underline: Container(),
          items: uniqueItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  value,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              if (label == 'Kode Pelanggan') {
                selectedKode = newValue;
              } 
            });
          },
        ),
      ),
    ],
  );
}

Widget buildDateButton(String label) {
  String dateText = 'Pilih Tanggal';
  Color textColor = Colors.grey[500]!;

  if (label == 'Tanggal Pesan') {
    dateText = _selectedTanggalPesan == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(_selectedTanggalPesan!);
    textColor = _selectedTanggalPesan == null ? Colors.grey[500]! : Colors.black;
  } else if (label == 'Tanggal Kirim') {
    dateText = _selectedTanggalKirim == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(_selectedTanggalKirim!);
    textColor = _selectedTanggalKirim == null ? Colors.grey[500]! : Colors.black;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: 8.0),
      ElevatedButton(
        onPressed: () {
          _selectDate(context, label);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
            ),
            SizedBox(width: 8.0),
            Text(
              dateText,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildDropdownDetail(String label, List<String> items, String selectedValue, void Function(String) onChanged) {
  List<String> uniqueItems = items.toSet().toList(); // Remove duplicates

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: 8.0),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue.isEmpty ? null : selectedValue,
          underline: Container(),
          items: uniqueItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  value,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            onChanged(newValue ?? ''); // Make sure to pass an empty string if newValue is null
          },
        ),
      ),
    ],
  );
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
              buildDropdownDetail(
                'Kode Produk',
                ['Kode 1', 'Kode 2'],
                productCardData.kodeProduk,
                (newValue) {
                  setState(() {
                    productCardData.kodeProduk = newValue;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              buildTextField('Nama Produk', 'Nama Produk'),
              const SizedBox(height: 8.0),
              buildTextField('Jumlah', 'Jumlah'),
              const SizedBox(height: 8.0),
              buildDropdownDetail(
                'Satuan',
                ['Satuan 1', 'Satuan 2'],
                productCardData.satuan,
                (newValue) {
                  setState(() {
                    productCardData.satuan = newValue;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              buildTextField('Harga Satuan', 'Harga Satuan', isEnabled: false),
              const SizedBox(height: 8.0),
              buildTextField('Subtotal', 'Subtotal', isEnabled: false),
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
                    'Pesanan Pelanggan',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              buildDropdown('Kode Pelanggan', ['Kode A', 'Kode B']),
              const SizedBox(height: 16.0,),
              buildTextField('Nama Pelanggan', 'Nama Pelanggan', isEnabled: false),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child: buildDateButton('Tanggal Pesan')),
                  SizedBox(width: 16.0),
                  Expanded(child: buildDateButton('Tanggal Kirim')),
                ],
              ),
              const SizedBox(height: 16),
              buildTextField('Alamat Pengiriman', 'Alamat', multiline: true),
              const SizedBox(height: 16.0,),
              buildTextField('Catatan', 'Catatan'),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child: buildTextField('Total Harga', 'Total Harga', isEnabled: false),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: buildTextField('Total Produk', 'Total Produk', isEnabled: false),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              buildTextField('Status', 'In Process', isEnabled: false),
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

