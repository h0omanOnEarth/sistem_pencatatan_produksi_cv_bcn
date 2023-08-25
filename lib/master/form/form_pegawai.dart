import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterPegawaiScreen extends StatefulWidget {
  static const routeName = '/form_master_pegawai_screen';

  const FormMasterPegawaiScreen({super.key});
  
  @override
  State<FormMasterPegawaiScreen> createState() =>
      _FormMasterPegawaiScreenState();
}

class _FormMasterPegawaiScreenState extends State<FormMasterPegawaiScreen> {
  DateTime? _selectedDate;
  String selectedPosisi = "Produksi";
  String selectedJenisKelamin = "Perempuan";
  String selectedStatus = "Aktif";

  @override
  Widget build(BuildContext context) {

    var namaController;
    var usernameController;
    var emailController;
    var passwordController;
    var nomorTeleponController;
    var alamatController;
    
    var gajiHarianController;
    var gajiLemburController;
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
                    const Text(
                      'Pegawai',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Nama Pegawai',
                  placeholder: 'Nama',
                  controller: namaController,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Username',
                  placeholder: 'Username',
                  controller: usernameController,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Email',
                  placeholder: 'Email',
                  controller: emailController,
                  isEmail: true,
                ),
                SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Password',
                  placeholder: 'Password',
                  controller: passwordController,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Alamat',
                  placeholder: 'Alamat',
                  controller: alamatController,
                  multiline: true,
                ),
                SizedBox(height: 28.0),
                TextFieldWidget(
                  label: 'Nomor Telepon',
                  placeholder: '(+62)xxxx-xxx-xxx',
                  controller: nomorTeleponController,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                          label: 'Posisi',
                          selectedValue: selectedPosisi, // Isi dengan nilai yang sesuai
                          items: ['Produksi', 'Gudang', 'Administrasi'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedPosisi = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                          label: 'Jenis Kelamin',
                          selectedValue: selectedJenisKelamin, // Isi dengan nilai yang sesuai
                          items: ['Perempuan','Laki-laki'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedJenisKelamin = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    DatePickerButton(
                        label: 'Tanggal Pesanan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                        label: 'Status',
                        selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                        items: ['Aktif', 'Tidak Aktif'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                 Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Gaji Harian',
                        placeholder: 'Gaji Harian',
                        controller: gajiHarianController,
                        isNumeric: true,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Gaji Lembur Harian',
                        placeholder: 'Gaji Lembur',
                        controller: gajiLemburController,
                        isNumeric: true,
                      ),
                    ),
                  ],
                ),
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
