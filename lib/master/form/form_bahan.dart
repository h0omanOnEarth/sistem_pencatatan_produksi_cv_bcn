import 'package:flutter/material.dart';

class FormMasterBahanScreen extends StatefulWidget {
  static const routeName = '/form_master_bahan_screen';

  const FormMasterBahanScreen({super.key});
  
  @override
  State<FormMasterBahanScreen> createState() =>
      _FormMasterBahanScreenState();
}

class _FormMasterBahanScreenState extends State<FormMasterBahanScreen> {
  String? selectedSupplier;
  String? selectedKategori;
  String? selectedSatuan;
  String? selectedStatus;


  Widget buildTextField(String label, String placeholder,
      {bool multiline = false}) {
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

  if (label == 'Supplier') {
    selectedValue = selectedSupplier;
  } else if (label == 'Kategori') {
    selectedValue = selectedKategori;
  } else if (label == 'Status') {
    selectedValue = selectedStatus;
  } else if (label == 'Satuan'){
    selectedValue = selectedSatuan;
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
              if (label == 'Kategori') {
                selectedKategori = newValue;
              } else if (label == 'Supplier') {
                selectedSupplier = newValue;
              } else if (label == 'Status') {
                selectedStatus = newValue;
              }else if (label == 'Satuan') {
                selectedSatuan = newValue;
              }
            });
          },
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
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.0),
                    Text(
                      'Bahan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                buildTextField('Nama Bahan', 'Nama'),
                SizedBox(height: 16.0),
                buildDropdown('Supplier', ['Supplier 1', 'Supplier 2']),
                SizedBox(height: 16.0),
                buildTextField('Harga', 'Harga'),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: buildDropdown('Kategori', ['Kategori 1', 'Kategori 2', 'Kategori 3']),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Satuan', ['Kg', 'Pcs', 'Sak', 'Ton', 'Ons', 'Gram']),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(child: buildTextField('Stok', 'Stok')),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Status', ['Aktif', 'Tidak Aktif']),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                buildTextField('Keterangan', 'Keterangan'),
                SizedBox(height: 16.0,),
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
                        child: Padding(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
