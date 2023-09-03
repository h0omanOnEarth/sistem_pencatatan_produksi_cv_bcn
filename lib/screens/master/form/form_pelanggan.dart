import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterPelangganScreen extends StatefulWidget {
  static const routeName = '/form_master_pelanggan_screen';

  const FormMasterPelangganScreen({super.key});
  @override
  State<FormMasterPelangganScreen> createState() => _FormMasterPelangganScreenState();
}

class _FormMasterPelangganScreenState extends State<FormMasterPelangganScreen> {
  @override
  Widget build(BuildContext context) {

    String selectedStatus = 'Aktif';
    var namaController;
    var alamatController;
    var nomorTeleponController;

    var nomorKantorController;
    var emailController;
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
                                    child: Icon(Icons.arrow_back, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            const Text(
                              'Pelaggan',
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
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Alamat',
                  placeholder: 'Alamat',
                  controller: alamatController,
                  multiline: true,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Nomor Telepon',
                  placeholder: '(+62)xxxx-xxx-xxx',
                  controller: nomorTeleponController,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                label: 'Nomor Telepon Kantor',
                placeholder: 'Nomor Telepon Kantor',
                controller: nomorKantorController,
              ),
                SizedBox(height: 16.0),
                 TextFieldWidget(
                  label: 'Email',
                  placeholder: 'Email',
                  controller: emailController,
                  isEmail: true,
                ),
                SizedBox(height: 16.0),
                DropdownWidget(
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
                SizedBox(height: 24.0,),
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
                  SizedBox(width: 16), // Add spacing between buttons
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
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


