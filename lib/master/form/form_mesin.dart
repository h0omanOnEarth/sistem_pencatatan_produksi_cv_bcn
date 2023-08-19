import 'package:flutter/material.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/form_master_mesin_screen';

  const FormMasterMesinScreen({super.key});
  
  @override
  State<FormMasterMesinScreen> createState() =>
      _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String? selectedTipe;
  String? selectedSupplier;
  String? selectedKondisi;
  String? selectedStatus;
  String? selectedUnit;


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
  } else if (label == 'Kondisi') {
    selectedValue = selectedKondisi;
  } else if (label == 'Status') {
    selectedValue = selectedStatus;
  } else if (label == 'Tipe'){
    selectedValue = selectedTipe;
  }else if( label == 'Unit'){
    selectedValue = selectedUnit;
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
              if (label == 'Tipe') {
                selectedTipe = newValue;
              } else if (label == 'Supplier') {
                selectedSupplier = newValue;
              } else if (label == 'Status') {
                selectedStatus = newValue;
              }else if (label == 'Kondisi') {
                selectedKondisi = newValue;
              }else if( label == 'Unit'){
                selectedUnit = newValue;
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
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.0),
                    const Text(
                      'Mesin',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                buildTextField('Nama Mesin', 'Nama'),
                SizedBox(height: 16.0),
                buildDropdown('Tipe', ['Penggiling', 'Pencampur', 'Pencetak']),
                SizedBox(height: 16.0),
                buildTextField('Nomor Seri', 'Nomor Seri'),
                SizedBox(height: 16.0,),
                 Row(
                  children: [
                    Expanded(
                      child: buildTextField('Kapasitas Produksi', 'Kapasitas'),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Unit', ['Kg', 'Pcs', 'Sak', 'Ton', 'Ons', 'Gram']),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                 Row(
                  children: [
                    Expanded(
                      child: buildTextField('Tahun Pembuatan', '20XX'),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildTextField('Tahun Perolehan', '20XX'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                buildDropdown('Supplier', ['Supplier 1', 'Supplier 2']),
                SizedBox(height: 16.0,),
                buildTextField('Keterangan', 'Keterangan'),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: buildDropdown('Status', ['Aktif', 'Tidak Aktif']),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildDropdown('Kondisi', ['Baru', 'Bekas']),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
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
