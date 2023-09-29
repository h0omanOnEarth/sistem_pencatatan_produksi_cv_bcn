import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/materials_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/material.dart';

class FormMasterBahanScreen extends StatefulWidget {
  static const routeName = '/form_master_bahan_screen';

  final String? materialId; // Terima ID pelanggan jika dalam mode edit
  const FormMasterBahanScreen({Key? key, this.materialId}) : super(key: key);

  @override
  State<FormMasterBahanScreen> createState() =>
      _FormMasterBahanScreenState();
}

class _FormMasterBahanScreenState extends State<FormMasterBahanScreen> {
  String selectedKategori = "Bahan Baku";
  String selectedSatuan = "Kg";
  String selectedStatus = "Aktif";
  bool isLoading = false;

  TextEditingController namaBahanController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  final MaterialBloc _materialBloc = MaterialBloc(); // Tambahkan ini di dalam widget class

  @override
  void initState() {
    super.initState();
    if (widget.materialId != null) {
      FirebaseFirestore.instance
          .collection('materials')
          .where('id', isEqualTo: widget.materialId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            selectedStatus = data['status'] == 1 ? 'Aktif' : 'Tidak Aktif';
            namaBahanController.text = data['nama'] ?? '';
            keteranganController.text = data['keterangan'] ?? '';
            selectedSatuan = data['satuan'] ?? '';
            stokController.text = data['stok'].toString();
            selectedKategori = data['jenis_bahan'] ?? '';
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
  }

  @override
  void dispose() {
    _materialBloc.close();
    super.dispose();
  }

  void _addMaterial() {
    final bahanBloc = BlocProvider.of<MaterialBloc>(context);
    int stok = 0; // Default stok
    try {
      stok = int.parse(stokController.text);
    } catch (e) {
      // Tangani kesalahan konversi ke int di sini
      print('Error parsing stok: $e');
    }

    final Bahan newMaterial = Bahan(
      id: '', // auto generate
      jenisBahan: selectedKategori,
      keterangan: keteranganController.text,
      nama: namaBahanController.text,
      satuan: selectedSatuan,
      status: selectedStatus == 'Aktif' ? 1 : 0,
      stok: stok, // Gunakan nilai stok yang telah di-parse
    );

    if (widget.materialId != null) {
      bahanBloc.add(UpdateMaterialEvent(widget.materialId ?? '', newMaterial));
    } else {
      bahanBloc.add(AddMaterialEvent(newMaterial));
    }
    setState(() {
      isLoading = true; // Aktifkan isLoading saat proses dimulai
    });
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan bahan.'),
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
      // Setelah dialog ditutup, navigasi kembali ke layar daftar pegawai
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialBloc, MaterialBlocState>(
      listener: (context, state) async {
        if (state is SuccessState) {
          _showSuccessMessageAndNavigateBack();
          setState(() {
            isLoading = false; // Matikan isLoading saat successState
          });
        } else if (state is ErrorState) {
          final snackbar = SnackBar(content: Text(state.errorMessage));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        } else if (state is LoadingState) {
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
              Center( // Membungkus konten dengan Center
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
                                Navigator.pop(context, null);
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
                              'Bahan',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        TextFieldWidget(
                          label: 'Nama Bahan',
                          placeholder: 'Nama',
                          controller: namaBahanController,
                        ),
                        const SizedBox(height: 16.0),
                        DropdownWidget(
                          label: 'Satuan',
                          selectedValue: selectedKategori, // Isi dengan nilai yang sesuai
                          items: const ['Bahan Baku', 'Bahan Tambahan'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedKategori = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        DropdownWidget(
                          label: 'Satuan',
                          selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                          items: const ['Kg', 'Ons', 'Pcs', 'Gram', 'Sak'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWidget(
                          label: 'Stok',
                          placeholder: 'Stok',
                          controller: stokController,
                        ),
                        const SizedBox(height: 16,),
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
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: 'Keterangan',
                          placeholder: 'Keterangan',
                          controller: keteranganController,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle save button press
                                  _addMaterial(); // Panggil method _addMaterial saat tombol "Simpan" ditekan
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
                                  namaBahanController.clear();
                                  hargaController.clear();
                                  stokController.clear();
                                  keteranganController.clear();
                                  selectedKategori = "Bahan Baku";
                                  selectedSatuan = "Kg";
                                  selectedStatus = "Aktif";
                                  isLoading = false;
                                  setState(() {});
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
          ),
        ),
      ),
    );
  }
}
