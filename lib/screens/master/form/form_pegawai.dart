import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/employee.dart';
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

  TextEditingController namaController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController gajiHarianController = TextEditingController();
  TextEditingController gajiLemburController = TextEditingController();

void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Sukses'),
        content: Text('Berhasil menyimpan pegawai.'),
        actions: [
          TextButton(
            onPressed: () {
              // Setelah menampilkan pesan sukses, navigasi kembali ke layar daftar pegawai
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  ).then((_) {
    // Setelah dialog ditutup, navigasi kembali ke layar daftar pegawai
    Navigator.pop(context);
  });
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeBloc(),
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
                          selectedValue: selectedPosisi,
                          items: ['Produksi', 'Gudang', 'Administrasi'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedPosisi = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Jenis Kelamin',
                          selectedValue: selectedJenisKelamin,
                          items: ['Perempuan', 'Laki-laki'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedJenisKelamin = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: DatePickerButton(
                          label: 'Tanggal Masuk',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Status',
                          selectedValue: selectedStatus,
                          items: ['Aktif', 'Tidak Aktif'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue;
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
                          label: 'Gaji Lembur Per Jam',
                          placeholder: 'Gaji Lembur',
                          controller: gajiLemburController,
                          isNumeric: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final employeeBloc =
                                BlocProvider.of<EmployeeBloc>(context);

                            employeeBloc.add(
                              AddEmployeeEvent(
                                Employee(
                                  id: '', // Atur ID sesuai dengan yang dibutuhkan
                                  email: emailController.text,
                                  password: passwordController.text,
                                  alamat: alamatController.text,
                                  gajiHarian: int.tryParse(gajiHarianController.text) ?? 0,
                                  gajiLemburJam: int.tryParse(gajiLemburController.text) ?? 0,
                                  jenisKelamin: selectedJenisKelamin,
                                  nama: namaController.text,
                                  nomorTelepon: nomorTeleponController.text,
                                  posisi: selectedPosisi,
                                  status: selectedStatus == 'Aktif' ? 1 : 0,
                                  tanggalMasuk: _selectedDate ?? DateTime.now(),
                                  username: usernameController.text,
                                ),
                              ),
                            );

                            _showSuccessMessageAndNavigateBack();
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
                            namaController.text = '';
                            usernameController.text = '';
                            emailController.text = '';
                            passwordController.text = '';
                            alamatController.text = '';
                            nomorTeleponController.text = '';
                            gajiHarianController.text = '';
                            gajiLemburController.text = '';

                            setState(() {
                              selectedPosisi = 'Produksi';
                              selectedJenisKelamin = 'Perempuan';
                              selectedStatus = 'Aktif';
                              _selectedDate = null;
                            });
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
                  BlocBuilder<EmployeeBloc, EmployeeState>(
                    builder: (context, state) {
                      if (state is ErrorState) {
                        return Text(state.errorMessage);
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
