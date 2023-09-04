import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/mesin_bloc.dart' as MesinBloc;
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/machine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/form_master_mesin_screen';

  const FormMasterMesinScreen({Key? key}) : super(key: key);

  @override
  State<FormMasterMesinScreen> createState() => _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String selectedTipe = "Penggiling";
  String? selectedSupplier; // Tipe data selectedSupplier diubah menjadi nullable
  String selectedKondisi = "Baru";
  String selectedStatus = "Aktif";
  String selectedSatuan = "Kg";

  TextEditingController namaController = TextEditingController();
  TextEditingController nomorSeriController = TextEditingController();
  TextEditingController kapasitasController = TextEditingController();
  TextEditingController tahunPembutanController = TextEditingController();
  TextEditingController tahunPerolehanController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  final MesinBloc.MesinBloc _machineBloc = MesinBloc.MesinBloc();

  @override
  void dispose() {
    _machineBloc.close();
    super.dispose();
  }

  void addMachine() {
    final machineBloc = BlocProvider.of<MesinBloc.MesinBloc>(context);
    final Mesin newMachine = Mesin(
      id: '',
      kapasitasProduksi: int.parse(kapasitasController.text),
      keterangan: catatanController.text,
      kondisi: selectedKondisi,
      nama: namaController.text,
      nomorSeri: nomorSeriController.text,
      satuan: selectedSatuan,
      status: selectedStatus == 'Aktif' ? 1 : 0,
      supplierId: selectedSupplier ?? '', // Gunakan null-aware operator untuk menghindari null
      tahunPembuatan: int.parse(tahunPembutanController.text),
      tahunPerolehan: int.parse(tahunPerolehanController.text),
      tipe: selectedTipe,
    );

    machineBloc.add(MesinBloc.AddMesinEvent(newMachine));

    _showSuccessMessageAndNavigateBack();
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan mesin.'),
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
      create: (context) => MesinBloc.MesinBloc(),
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
                      const SizedBox(width: 24.0),
                      const Text(
                        'Mesin',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  TextFieldWidget(
                    label: 'Nama Mesin',
                    placeholder: 'Nama',
                    controller: namaController,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownWidget(
                    label: 'Tipe',
                    selectedValue: selectedTipe,
                    items: const ['Penggiling', 'Pencampur', 'Pencetak', 'Sheet'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedTipe = newValue;
                        print('Selected value: $newValue');
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Nomor Seri',
                    placeholder: 'Nomor Seri',
                    controller: nomorSeriController,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          label: 'Kapasitas Produksi',
                          placeholder: 'Kapasitas Produksi',
                          controller: kapasitasController,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Satuan',
                          selectedValue: selectedSatuan,
                          items: const ['Kg', 'Ons', 'Pcs', 'Gram', 'Sak'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedSatuan = newValue;
                              print('Selected value: $newValue');
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          label: 'Tahun Pembuatan',
                          placeholder: '20XX',
                          controller: tahunPembutanController,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: TextFieldWidget(
                          label: 'Tahun Perolehan',
                          placeholder: '20XX',
                          controller: tahunPerolehanController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      List<DropdownMenuItem<String>> supplierItems = [];

                      for (QueryDocumentSnapshot document in snapshot.data!.docs) {
                        String supplierName = document['nama'] ?? '';
                        String supplierId = document.id;
                        supplierItems.add(
                          DropdownMenuItem<String>(
                            value: supplierId,
                            child: Text(supplierName),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Supplier',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey[400]!), // Warna abu-abu 400
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey[400]!), // Warna abu-abu 400 saat fokus
                          ),
                        ),
                        value: selectedSupplier,
                        items: supplierItems,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSupplier = newValue;
                            print('Selected value: $newValue');
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Catatan',
                    placeholder: 'Catatan',
                    controller: catatanController,
                    multiline: true,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownWidget(
                          label: 'Status',
                          selectedValue: selectedStatus,
                          items: const ['Aktif', 'Tidak Aktif'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue;
                              print('Selected value: $newValue');
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownWidget(
                          label: 'Kondisi',
                          selectedValue: selectedKondisi,
                          items: const ['Baru', 'Bekas', 'Baik', 'Buruk'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedKondisi = newValue;
                              print('Selected value: $newValue');
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
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle save button press
                            addMachine(); // Panggil method addMachine saat tombol "Simpan" ditekan
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
                            // Handle clear button press
                            namaController.clear();
                            nomorSeriController.clear();
                            kapasitasController.clear();
                            tahunPembutanController.clear();
                            tahunPerolehanController.clear();
                            catatanController.clear();
                            selectedTipe = "Penggiling";
                            selectedSupplier = null; // Mengosongkan selectedSupplier
                            selectedKondisi = "Baru";
                            selectedStatus = "Aktif";
                            selectedSatuan = "Kg";
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
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
                  BlocBuilder<MesinBloc.MesinBloc, MesinBloc.MesinState>(
                    builder: (context, state) {
                      if (state is MesinBloc.ErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage),
                            duration: Duration(seconds: 2), // Sesuaikan dengan durasi yang Anda inginkan
                          ),
                        );
                      }
                      return SizedBox.shrink();
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
