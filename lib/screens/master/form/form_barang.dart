import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/products_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/product.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterBarangScreen extends StatefulWidget {
  static const routeName = '/master/barang/form';

  final String? productId;
  const FormMasterBarangScreen({Key? key, this.productId}) : super(key: key);

  @override
  State<FormMasterBarangScreen> createState() => _FormMasterBarangScreenState();
}

class _FormMasterBarangScreenState extends State<FormMasterBarangScreen> {
  String selectedJenis = "Gelas Pop";
  String selectedSatuan = "Kg";
  String selectedStatus = "Aktif";
  bool isLoading = false;

  TextEditingController namaController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController dimensiController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController ketebalanController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController banyaknyaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      FirebaseFirestore.instance
          .collection('products')
          .where('id', isEqualTo: widget.productId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            selectedStatus = data['status'] == 1 ? 'Aktif' : 'Tidak Aktif';
            namaController.text = data['nama'] ?? '';
            beratController.text = data['berat'].toString();
            deskripsiController.text = data['deskripsi'] ?? '';
            dimensiController.text = data['dimensi'].toString();
            hargaController.text = data['harga'].toString();
            banyaknyaController.text = data['banyaknya'].toString();
            selectedJenis = data['jenis'];
            ketebalanController.text = data['ketebalan'].toString();
            selectedSatuan = data['satuan'];
            stokController.text = data['stok'].toString();
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
  }

  void modifiedProduct() {
    final productBloc = BlocProvider.of<ProductBloc>(context);

    final berat = double.tryParse(beratController.text);
    final dimensi = int.tryParse(dimensiController.text);
    final harga = int.tryParse(hargaController.text);
    final ketebalan = int.tryParse(ketebalanController.text);
    final stok = int.tryParse(stokController.text);

    final Product newProduct = Product(
        id: '',
        nama: namaController.text,
        deskripsi: deskripsiController.text,
        jenis: selectedJenis,
        satuan: selectedSatuan,
        berat: berat ?? 0.0, // Berikan nilai default jika null
        dimensi: dimensi ?? 0, // Berikan nilai default jika null
        harga: harga ?? 0, // Berikan nilai default jika null
        ketebalan: ketebalan ?? 0, // Berikan nilai default jika null
        status: selectedStatus == 'Aktif' ? 1 : 0,
        stok: stok ?? 0, // Berikan nilai default jika null
        banyaknya: int.tryParse(banyaknyaController.text) ?? 0);

    if (widget.productId != null) {
      productBloc.add(UpdateProductEvent(widget.productId ?? '', newProduct));
    } else {
      productBloc.add(AddProductEvent(newProduct));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan Produk',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductBlocState>(
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
              Center(
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
                                  child: Icon(Icons.arrow_back,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            const Text(
                              'Barang',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        TextFieldWidget(
                          label: 'Nama Barang',
                          placeholder: 'Nama',
                          controller: namaController,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWidget(
                          label: 'Harga Satuan',
                          placeholder: 'Harga',
                          controller: hargaController,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWidget(
                          label: 'Deskripsi',
                          placeholder: 'Deskripsi',
                          controller: deskripsiController,
                          multiline: true,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        DropdownWidget(
                          label: 'Status',
                          selectedValue:
                              selectedStatus, // Isi dengan nilai yang sesuai
                          items: const ['Aktif', 'Tidak Aktif'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus =
                                  newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownWidget(
                                label: 'Jenis',
                                selectedValue:
                                    selectedJenis, // Isi dengan nilai yang sesuai
                                items: const ['Gelas Pop', 'Gelas Cup'],
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedJenis =
                                        newValue; // Update _selectedValue saat nilai berubah
                                    print('Selected value: $newValue');
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: DropdownWidget(
                                label: 'Satuan',
                                selectedValue:
                                    selectedSatuan, // Isi dengan nilai yang sesuai
                                items: const [
                                  'Kg',
                                  'Ons',
                                  'Pcs',
                                  'Gram',
                                  'Sak'
                                ],
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedSatuan =
                                        newValue; // Update _selectedValue saat nilai berubah
                                    print('Selected value: $newValue');
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        TextFieldWidget(
                          label: 'Banyaknya (Per Dus)',
                          placeholder: '0',
                          controller: banyaknyaController,
                        ),
                        const SizedBox(height: 24.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Dimensi (cm)',
                                placeholder: 'Dimensi',
                                controller: dimensiController,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Berat (gram)',
                                placeholder: 'Berat',
                                controller: beratController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Ketebalan (mm)',
                                placeholder: 'Ketebalan',
                                controller: ketebalanController,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Stok',
                                placeholder: 'Stok',
                                controller: stokController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle save button press
                                  modifiedProduct();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 51, 51, 1),
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
                                  hargaController.clear();
                                  deskripsiController.clear();
                                  dimensiController.clear();
                                  beratController.clear();
                                  ketebalanController.clear();
                                  banyaknyaController.clear();
                                  stokController.clear();
                                  selectedJenis = "Gelas Pop";
                                  selectedSatuan = "Kg";
                                  selectedStatus = "Aktif";
                                  isLoading = false;
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 51, 51, 1),
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
          )),
        ));
  }
}
