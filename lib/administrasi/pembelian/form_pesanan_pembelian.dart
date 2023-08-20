import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class FormPesananPembelianScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pembelian_screen';

  const FormPesananPembelianScreen({super.key});
  
  @override
  State<FormPesananPembelianScreen> createState() =>
      _FormPesananPembelianScreenState();
}

class _FormPesananPembelianScreenState extends State<FormPesananPembelianScreen> {
  DateTime? _selectedTanggalPengiriman;
  DateTime? _selectedTanggalPesanan;
  String? selectedKode;
  String? selectedSupplier;
  String? selectedSatuan;
  String? selectedStatusPembayaran;
  String? selectedStatusPengiriman;

Future<void> _selectDate(BuildContext context, String label) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (pickedDate != null && pickedDate != _selectedTanggalPesanan && pickedDate !=_selectedTanggalPengiriman) {
    print("Picked Date: $pickedDate"); // Check if pickedDate is correct
    setState(() {
      if(label=='Tanggal Pesanan'){
        _selectedTanggalPesanan = pickedDate;
        print("_selectedDate: $_selectedTanggalPesanan"); // Check if _selectedDate is updated
      }else if(label== 'Tanggal Pengiriman'){
        _selectedTanggalPengiriman = pickedDate;
        print("_selectedDate: $_selectedTanggalPengiriman"); // Check if _selectedDate is updated
      }
    });
  }
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
            fillColor: Colors.white,
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

  if (label == 'Kode') {
    selectedValue = selectedKode;
  } else if (label == 'Supplier') {
    selectedValue = selectedSupplier;
  } else if (label == 'Satuan') {
    selectedValue = selectedSatuan;
  } else if(label== 'Status Pembayaran'){
    selectedValue = selectedStatusPembayaran;
  }else if (label== 'Status Pengiriman'){
    selectedValue = selectedStatusPengiriman;
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
              if (label == 'Kode') {
                selectedKode = newValue;
              } else if (label == 'Supplier') {
                selectedSupplier = newValue;
              } else if (label == 'Satuan') {
                selectedSatuan = newValue;
              }else if (label == 'Status Pembayaran') {
                selectedStatusPembayaran = newValue;
              }else if (label == 'Status Pengiriman') {
                selectedStatusPengiriman = newValue;
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

  if (label == 'Tanggal Pesanan') {
    dateText = _selectedTanggalPesanan == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(_selectedTanggalPesanan!);
    textColor = _selectedTanggalPesanan == null ? Colors.grey[500]! : Colors.black;
  } else if (label == 'Tanggal Pengiriman') {
    dateText = _selectedTanggalPengiriman == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(_selectedTanggalPengiriman!);
    textColor = _selectedTanggalPengiriman == null ? Colors.grey[500]! : Colors.black;
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
                        child:const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                   const SizedBox(width: 16.0),
                    const Text(
                      'Pesanan Pembelian',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: buildDropdown('Kode', ['Kode A', 'Kode B', 'Kode C']),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildTextField('Nama Bahan', 'Nama Bahan', isEnabled: false),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                buildDropdown('Supplier', ['Supplier 1', 'Supplier 2']),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: buildTextField('Jumlah', 'Jumlah')),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Satuan', ['Kg', 'Gram', 'Ons', 'Inc']),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                 Row(
                  children: [
                    Expanded(
                      child: buildTextField('Harga Satuan', 'Harga Satuan'),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildTextField('Total', 'Total', isEnabled: false),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: buildDateButton('Tanggal Pesanan'),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDateButton('Tanggal Pengiriman')
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: buildDropdown('Status Pembayaran', ['Belum Bayar','Dalam Proses','Selesai']),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Status Pengiriman', ['Dalam Proses', 'Selesai']),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                buildTextField('Keterangan', 'Keterangan'),
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
