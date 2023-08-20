import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class FormPengembalianPesananScreen extends StatefulWidget {
  static const routeName = '/form_pengembalian_pesanan_pembelian_screen';

  const FormPengembalianPesananScreen({super.key});
  
  @override
  State<FormPengembalianPesananScreen> createState() =>
      _FormPengembalianPesananScreenState();
}

class _FormPengembalianPesananScreenState extends State<FormPengembalianPesananScreen> {
  DateTime? _selectedDate;
  String? _selectedPesanan;
  String? _selectedSatuan;
  String? _selectedStatus;
  

Future<void> _selectDate(BuildContext context, String label) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (pickedDate != null && pickedDate != _selectedDate) {
    print("Picked Date: $pickedDate"); // Check if pickedDate is correct
    setState(() {
        _selectedDate = pickedDate;
        print("_selectedDate: $_selectedDate"); 
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

  if (label == 'Nomor Pesanan') {
    selectedValue = _selectedPesanan;
  } else if (label == 'Satuan') {
    selectedValue = _selectedSatuan;
  }else if(label=='Status'){
    selectedValue = _selectedStatus;
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
              if (label == 'Nomor Pesanan') {
                _selectedPesanan = newValue;
              } else if (label == 'Satuan') {
                _selectedSatuan = newValue;
              }else if(label=='Status'){
                _selectedStatus = newValue;
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

    dateText = _selectedDate == null
        ? 'Pilih Tanggal'
        : DateFormat.yMMMMd().format(_selectedDate!);
    textColor = _selectedDate == null ? Colors.grey[500]! : Colors.black;

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
                      'Pengembalian Pesanan Pembelian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                buildDropdown('Nomor Pesanan', ['Nomor Pesanan A','Nomor Pesanan B']),
                const SizedBox(height: 16.0,),
                buildTextField('Tanggal Pemesanan', 'Tanggal Pemesanan', isEnabled: false),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField('Kode Bahan', 'Kode Bahan', isEnabled: false),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: buildTextField('Nama Bahan', 'Nama Bahan', isEnabled: false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextField('Supplier', 'Nama Supplier', isEnabled: false),
                const SizedBox(height: 16.0,),
                buildTextField('Alamat Pengembalian', 'Alamat Pengembalian', multiline: true),
                const SizedBox(height: 16.0,),
                buildDateButton('Tanggal Pengembalian'),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField('Jumlah', 'Jumlah')
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Satuan',['Kg','Ons','Pcs','Gram','Sak']),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                buildDropdown('Status', ['Aktif','Tidak Aktif']),
                const SizedBox(height: 16.0,),
                buildTextField('Alasan', 'Alasan', multiline: true),
                const SizedBox(height: 16.0,),
                buildTextField('Catatan', 'Catatan'),
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
