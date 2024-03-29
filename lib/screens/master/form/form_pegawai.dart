import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/employee.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterPegawaiScreen extends StatefulWidget {
  static const routeName = '/master/pegawai/form';

  final String? pegawaiId; // Terima ID pegawai jika dalam mode edit
  final String? currentUsername;
  const FormMasterPegawaiScreen(
      {Key? key, this.pegawaiId, this.currentUsername})
      : super(key: key);

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
  bool isLoading = false;
  int _selectedIndex = 1;
  bool _isSidebarCollapsed = false;
  bool isDesktop = false;

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
                Navigator.pop(context, null);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      if (isDesktop == true) {
        Routemaster.of(context).push(ListMasterPegawaiScreen.routeName);
      } else {
        Navigator.pop(context, null);
      }
    });
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
          child: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              if (sizingInformation.deviceScreenType ==
                  DeviceScreenType.desktop) {
                isDesktop = true;
                return _buildDesktopContent();
              } else {
                return _buildMobileContent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return buildContent();
  }

  Widget _buildDesktopContent() {
    return Row(
      children: [
        SidebarAdministrasiWidget(
            selectedIndex: _selectedIndex,
            onItemTapped: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // Implementasi navigasi berdasarkan index terpilih
              _navigateToScreen(index, context);
            },
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: _toggleSidebar),
        Expanded(child: buildContent())
      ],
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // Fungsi navigasi berdasarkan index terpilih
  void _navigateToScreen(int index, BuildContext context) {
    Routemaster.of(context)
        .push('${MainAdministrasi.routeName}?selectedIndex=$index');
  }

  Widget buildContent() {
    final bool isEditMode = widget.pegawaiId != null;
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isDesktop == true) {
                          Routemaster.of(context)
                              .push(ListMasterPegawaiScreen.routeName);
                        } else {
                          Navigator.pop(context, null); // Navigates back
                        }
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
                        items: const [
                          'Produksi',
                          'Kepala Produksi',
                          'Gudang',
                          'Administrasi'
                        ],
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
                DatePickerButton(
                  label: 'Tanggal Masuk',
                  selectedDate: _selectedDate,
                  onDateSelected: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownWidget(
                  label: 'Status',
                  selectedValue: selectedStatus,
                  items: const ['Aktif', 'Tidak Aktif'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
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
                          final employeeBloc =
                              BlocProvider.of<EmployeeBloc>(context);
                          final gajiHarian =
                              int.tryParse(gajiHarianController.text) ?? 0;
                          final gajiLemburJam =
                              int.tryParse(gajiLemburController.text) ?? 0;
                          final Employee newEmployee = Employee(
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
                            employeeBloc.add(UpdateEmployeeEvent(
                                widget.pegawaiId ?? '',
                                newEmployee,
                                widget.currentUsername ?? ''));
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
                          padding: EdgeInsets.symmetric(vertical: 16.0),
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
                            isLoading = false;
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
        if (isLoading)
          Positioned(
            // Menambahkan Positioned untuk indikator loading
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white
                  .withOpacity(0.3), // Latar belakang semi-transparan
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
