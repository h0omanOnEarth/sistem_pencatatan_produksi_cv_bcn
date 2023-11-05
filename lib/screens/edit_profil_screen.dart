import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/employee.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/roundedTextfieldWidget.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/profile/edit';
  final String? email;

  const EditProfileScreen({Key? key, this.email}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firestore = FirebaseFirestore.instance;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Employee _employee;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      // Cek jika widget.email tidak null
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    final querySnapshot = await firestore
        .collection('employees')
        .where('email', isEqualTo: widget.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first;
      setState(() {
        _namaController.text = userData['nama'] ?? '';
        _nomorTeleponController.text = userData['nomor_telepon'] ?? '';
        _alamatController.text = userData['alamat'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _employee = Employee(
            id: userData['id'],
            email: userData['email'],
            password: userData['password'],
            alamat: userData['alamat'],
            gajiHarian: userData['gaji_harian'],
            gajiLemburJam: userData['gaji_lembur_jam'],
            jenisKelamin: userData['jenis_kelamin'],
            nama: userData['email'],
            nomorTelepon: userData['nomor_telepon'],
            posisi: userData['posisi'],
            status: userData['status'],
            tanggalMasuk: (userData['tanggal_masuk'] as Timestamp).toDate(),
            username: userData['username']);
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
                Navigator.pop(context, null);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  void updatePegawai() {
    final employeeBloc = BlocProvider.of<EmployeeBloc>(context);
    final newEmployee = Employee(
        id: _employee.id,
        email: _emailController.text,
        password: _employee.password,
        alamat: _alamatController.text,
        gajiHarian: _employee.gajiHarian,
        gajiLemburJam: _employee.gajiLemburJam,
        jenisKelamin: _employee.jenisKelamin,
        nama: _namaController.text,
        nomorTelepon: _nomorTeleponController.text,
        posisi: _employee.posisi,
        status: _employee.status,
        tanggalMasuk: _employee.tanggalMasuk,
        username: _employee.username);
    employeeBloc.add(
        UpdateProfileEmployeeEvent(_employee.id, newEmployee, _employee.email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is ErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            );
          } else if (state is LoadingState) {
            setState(() {
              isLoading = true; // Aktifkan isLoading saat LoadingState
            });
          }
          if (state is! LoadingState) {
            setState(() {
              isLoading = false;
            });
          }
        },
        child: Scaffold(
          body: SafeArea(
              child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 8.0),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: InkWell(
                                      onTap: () {
                                        // Handle back button press
                                        Navigator.pop(
                                            context); // Navigates back
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Icon(Icons.arrow_back,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24.0),
                                  const Text(
                                    'Sunting Profile',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 24.0), // Add spacing between header and cards
                      RoundedTextField(
                        label: 'Nama',
                        placeholder: 'Masukkan nama',
                        controller: _namaController,
                      ),
                      const SizedBox(height: 16.0),
                      RoundedTextField(
                        label: 'Nomor Telepon',
                        placeholder: 'Masukkan nomor telepon',
                        controller: _nomorTeleponController,
                      ),
                      const SizedBox(height: 16.0),
                      RoundedTextField(
                        label: 'Alamat',
                        placeholder: 'Masukkan alamat',
                        controller: _alamatController,
                      ),
                      const SizedBox(height: 16.0),
                      RoundedTextField(
                        label: 'Email',
                        placeholder: 'Masukkan email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          updatePegawai();
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
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Positioned(
                  // Menambahkan Positioned untuk indikator loading
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.3), // Latar belakang semi-transparan
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          )),
        ));
  }
}
