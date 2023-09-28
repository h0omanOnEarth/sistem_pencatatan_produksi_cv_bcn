import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/employee.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterPegawaiScreen extends StatefulWidget {
  static const routeName = '/form_master_pegawai_screen';

  final String? pegawaiId; // Terima ID pegawai jika dalam mode edit
  const FormMasterPegawaiScreen({Key? key, this.pegawaiId}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    // Jika dalam mode edit, isi form dengan data pelanggan yang sesuai
   if (widget.pegawaiId != null) {
      FirebaseFirestore.instance
        .collection('employees')
        .where('id', isEqualTo: widget.pegawaiId)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
            setState(() {
              selectedStatus = data['status'] == 1 ? 'Aktif' : 'Tidak Aktif';
              namaController.text = data['nama'] ?? '';
              alamatController.text = data['alamat'] ?? '';
              nomorTeleponController.text = data['nomor_telepon'] ?? '';
              emailController.text = data['email'] ?? '';
              gajiHarianController.text = data['gaji_harian'] != null
                  ? data['gaji_harian'].toString()
                  : '';
              gajiLemburController.text = data['gaji_lembur_jam'] != null
                  ? data['gaji_lembur_jam'].toString()
                  : '';
              selectedJenisKelamin = data['jenis_kelamin'] ?? '';
              passwordController.text = data['password'] ?? '';
              usernameController.text = data['username'] ?? '';
              // Mengambil dan mengonversi data tanggal_masuk dari Firestore
              final tanggalMasukFirestore = data['tanggal_masuk'];
              if (tanggalMasukFirestore != null) {
                final tanggalMasukFirestore = data['tanggal_masuk'];
                if (tanggalMasukFirestore != null) {
                  _selectedDate = tanggalMasukFirestore.toDate();
                }

              }

            });
          } else {
            print('Document does not exist on Firestore');
          }
        }).catchError((error) {
          print('Error getting document: $error');
        });
    }
  }

void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sukses'),
        content: const Text('Berhasil menyimpan pegawai.'),
        actions: [
          TextButton(
            onPressed: () {
              // Setelah menampilkan pesan sukses, navigasi kembali ke layar daftar pegawai
              Navigator.pop(context,null);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  ).then((_) {
    // Setelah dialog ditutup, navigasi kembali ke layar daftar pegawai
    Navigator.pop(context,null);
  });
}

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.pegawaiId != null;
    return BlocListener<EmployeeBloc, EmployeeState>(
        listener: (context, state) async{
          if (state is SuccessState){
            _showSuccessMessageAndNavigateBack();
          } else if (state is ErrorState) {
            final snackbar = SnackBar(content: Text(state.errorMessage));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          }
        },
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
                          Navigator.pop(context,null);
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
                      const SizedBox(width: 24.0),
                      const Text(
                        'Pegawai',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  TextFieldWidget(
                    label: 'Nama Pegawai',
                    placeholder: 'Nama',
                    controller: namaController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Username',
                    placeholder: 'Username',
                    controller: usernameController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Email',
                    placeholder: 'Email',
                    controller: emailController,
                    isEmail: true,
                    isEnabled: !isEditMode,
                  ),
                  const SizedBox(height: 24.0),
                  TextFieldWidget(
                    label: 'Password',
                    placeholder: 'Password',
                    controller: passwordController,
                    isEnabled: !isEditMode,
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Alamat',
                    placeholder: 'Alamat',
                    controller: alamatController,
                    multiline: true,
                  ),
                  const SizedBox(height: 28.0),
                  TextFieldWidget(
                    label: 'Nomor Telepon',
                    placeholder: '(+62)xxxx-xxx-xxx',
                    controller: nomorTeleponController,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownWidget(
                          label: 'Posisi',
                          selectedValue: selectedPosisi,
                          items: const ['Produksi', 'Gudang', 'Administrasi'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedPosisi = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Jenis Kelamin',
                          selectedValue: selectedJenisKelamin,
                          items: const ['Perempuan', 'Laki-laki'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedJenisKelamin = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
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
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Status',
                          selectedValue: selectedStatus,
                          items: const ['Aktif', 'Tidak Aktif'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 16.0),
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
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final employeeBloc =BlocProvider.of<EmployeeBloc>(context);
                            final gajiHarian = int.tryParse(gajiHarianController.text) ?? 0;
                            final gajiLemburJam = int.tryParse(gajiLemburController.text) ?? 0;
                            final Employee newEmployee =   Employee(
                                  id: '', // Atur ID sesuai dengan yang dibutuhkan
                                  email: emailController.text,
                                  password: passwordController.text,
                                  alamat: alamatController.text,
                                  gajiHarian: gajiHarian,
                                  gajiLemburJam: gajiLemburJam,
                                  jenisKelamin: selectedJenisKelamin,
                                  nama: namaController.text,
                                  nomorTelepon: nomorTeleponController.text,
                                  posisi: selectedPosisi,
                                  status: selectedStatus == 'Aktif' ? 1 : 0,
                                  tanggalMasuk: _selectedDate ?? DateTime.now(),
                                  username: usernameController.text,
                                );
                            if (widget.pegawaiId != null) {
                              employeeBloc.add(UpdateEmployeeEvent(widget.pegawaiId ?? '',newEmployee));
                            } else {
                              employeeBloc.add(AddEmployeeEvent(newEmployee));
                            }
                           
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
                            backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
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
      ),
    );
  }
}
