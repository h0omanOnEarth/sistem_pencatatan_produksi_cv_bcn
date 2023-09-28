import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/customers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/customer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterPelangganScreen extends StatefulWidget {
  static const routeName = '/form_master_pelanggan_screen';

  final String? customerId; // Terima ID pelanggan jika dalam mode edit
  const FormMasterPelangganScreen({Key? key, this.customerId}) : super(key: key);

  @override
  State<FormMasterPelangganScreen> createState() => _FormMasterPelangganScreenState();
}

class _FormMasterPelangganScreenState extends State<FormMasterPelangganScreen> {
  String selectedStatus = 'Aktif';
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();
  TextEditingController nomorKantorController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Jika dalam mode edit, isi form dengan data pelanggan yang sesuai
   if (widget.customerId != null) {
      FirebaseFirestore.instance
        .collection('customers')
        .where('id', isEqualTo: widget.customerId)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
            setState(() {
              selectedStatus = data['status'] == 1 ? 'Aktif' : 'Tidak Aktif';
              namaController.text = data['nama'] ?? '';
              alamatController.text = data['alamat'] ?? '';
              nomorTeleponController.text = data['nomor_telepon'] ?? '';
              nomorKantorController.text = data['nomor_telepon_kantor'] ?? '';
              emailController.text = data['email'] ?? '';
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
          content: const Text('Berhasil menyimpan customer.'),
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
    return BlocListener<CustomerBloc, CustomerBlocState>(
        listener: (context, state) async{
          if (state is SuccessState){
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is ErrorState) {
            final snackbar = SnackBar(content: Text(state.errorMessage));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          }else if (state is LoadingState) {
            setState(() {
              isLoading = true; // Aktifkan isLoading saat LoadingState
            });
          }

           // Hanya jika bukan LoadingState, atur isLoading ke false
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
                                        Navigator.pop(context,null); // Navigates back
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
                                  ),
                                  const SizedBox(width: 24.0),
                                  const Text(
                                    'Pelanggan',
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
                      const SizedBox(height: 16.0), // Add spacing between header and cards
                      TextFieldWidget(
                        label: 'Nama Pelanggan',
                        placeholder: 'Nama',
                        controller: namaController,
                      ),
                      const SizedBox(height: 16.0),
                      TextFieldWidget(
                        label: 'Alamat',
                        placeholder: 'Alamat',
                        controller: alamatController,
                        multiline: true,
                      ),
                      const SizedBox(height: 16.0),
                      TextFieldWidget(
                        label: 'Nomor Telepon',
                        placeholder: '(+62)xxxx-xxx-xxx',
                        controller: nomorTeleponController,
                      ),
                      const SizedBox(height: 16.0),
                      TextFieldWidget(
                        label: 'Nomor Telepon Kantor',
                        placeholder: 'Nomor Telepon Kantor',
                        controller: nomorKantorController,
                      ),
                      const SizedBox(height: 16.0),
                      TextFieldWidget(
                        label: 'Email',
                        placeholder: 'Email',
                        controller: emailController,
                        isEmail: true,
                      ),
                      const SizedBox(height: 16.0),
                      DropdownWidget(
                        label: 'Status',
                        selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                        items: const ['Aktif', 'Tidak Aktif'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                            print('Selected value: $newValue');
                          });
                        },
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle save button press
                                final customerBloc = BlocProvider.of<CustomerBloc>(context);
                                final Customer newCustomer = Customer(
                                  id: widget.customerId ?? '', // Gunakan widget.customerId jika ada
                                  nama: namaController.text,
                                  alamat: alamatController.text,
                                  nomorTelepon: nomorTeleponController.text,
                                  nomorTeleponKantor: nomorKantorController.text,
                                  email: emailController.text,
                                  status: selectedStatus == 'Aktif' ? 1 : 0,
                                );
                                if (widget.customerId != null) {
                                  // Jika dalam mode edit, kirim event edit pelanggan
                                  customerBloc.add(UpdateCustomerEvent(widget.customerId ?? '',newCustomer));
                                } else {
                                  // Jika dalam mode tambah, kirim event tambah pelanggan
                                  customerBloc.add(AddCustomerEvent(newCustomer));
                                }

                                setState(() {
                                  isLoading = true; // Aktifkan isLoading saat proses dimulai
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
                                  'Simpan',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16), // Add spacing between buttons
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle clear button press
                                setState(() {
                                  selectedStatus = 'Aktif';
                                  namaController.clear();
                                  alamatController.clear();
                                  nomorTeleponController.clear();
                                  nomorKantorController.clear();
                                  emailController.clear();
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
                Positioned( // Menambahkan Positioned untuk indikator loading
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Latar belakang semi-transparan
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
               ),
            ],
          )
        ),
      ),
    );
  }
}
