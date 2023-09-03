import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterSupplierScreen extends StatefulWidget {
  static const routeName = '/form_master_supplier_screen';

  const FormMasterSupplierScreen({super.key});
  @override
  State<FormMasterSupplierScreen> createState() =>
      _FormMasterSupplierScreenState();
}

class _FormMasterSupplierScreenState extends State<FormMasterSupplierScreen> {
  String selectedJenis = 'Bahan Baku'; // Set initial selected option

  @override
  Widget build(BuildContext context) {
    String selectedStatus = 'Aktif';

    final TextEditingController namaController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController nomorTeleponController = TextEditingController();
    final TextEditingController nomorKantorController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    final SupplierBloc _supplierBloc = BlocProvider.of<SupplierBloc>(context);

    void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan supplier.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman daftar supplier
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                            SizedBox(width: 8.0),
                            Align(
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  // Handle back button press
                                  Navigator.pop(context); // Navigates back
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
                                    child:
                                        Icon(Icons.arrow_back, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            const Text(
                              'Supplier',
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
                const SizedBox(height: 24.0), 
                TextFieldWidget(
                label: 'Nama Supplier',
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
                      label: 'Jenis Supplier',
                      selectedValue: selectedJenis, // Isi dengan nilai yang sesuai
                      items: const ['Bahan Baku','Bahan Tambahan'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedJenis = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
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
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                           final Supplier newSupplier = Supplier(
                            nama: namaController.text,
                            alamat: alamatController.text,
                            noTelepon: nomorTeleponController.text,
                            noTeleponKantor: nomorKantorController.text,
                            email: emailController.text,
                            jenisSupplier: selectedJenis,
                            status: selectedStatus == 'Aktif' ? 1 : 0,
                          );

                          final AddSupplierEvent addEvent =
                              AddSupplierEvent(newSupplier);
                          _supplierBloc.add(addEvent);

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
                    SizedBox(width: 16), // Add spacing between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle clear button press
                          // Membersihkan controller
                          namaController.clear();
                          alamatController.clear();
                          nomorTeleponController.clear();
                          nomorKantorController.clear();
                          emailController.clear();
                          // Set selectedStatus kembali ke 'Aktif'
                          selectedStatus = 'Aktif';
                          // Refresh tampilan
                          setState(() {});
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

