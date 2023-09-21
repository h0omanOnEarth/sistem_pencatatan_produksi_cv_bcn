import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/products_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/product.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterBarangScreen extends StatefulWidget {
  static const routeName = '/form_master_barang_screen';

  final String? productId;
  const FormMasterBarangScreen({Key? key, this.productId}) : super(key: key);
  
  @override
  State<FormMasterBarangScreen> createState() =>
      _FormMasterBarangScreenState();
}

class _FormMasterBarangScreenState extends State<FormMasterBarangScreen> {
  String selectedJenis = "Gelas Pop";
  String selectedSatuan = "Kg";
  String selectedStatus = "Aktif";

  TextEditingController namaController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController dimensiController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController ketebalanController = TextEditingController();
  TextEditingController stokController = TextEditingController();

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

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan barang.'),
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
      create: (context) => ProductBloc(),
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
                      'Barang',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Nama Barang',
                  placeholder: 'Nama',
                  controller: namaController,
                ),
                SizedBox(height: 16.0),
                 TextFieldWidget(
                  label: 'Harga Satuan',
                  placeholder: 'Harga',
                  controller: hargaController,
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Deskripsi',
                  placeholder: 'Deskripsi',
                  controller: deskripsiController,
                  multiline: true,
                ),
                SizedBox(height: 16.0,),
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
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                      label: 'Jenis',
                      selectedValue: selectedJenis, // Isi dengan nilai yang sesuai
                      items: ['Gelas Pop', 'Gelas Cup'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedJenis = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                      items: ['Kg','Ons','Pcs','Gram','Sak'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(child: TextFieldWidget(
                                    label: 'Dimensi (cm)',
                                    placeholder: 'Dimensi',
                                    controller: dimensiController,
                                  ),),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Berat (gram)',
                        placeholder: 'Berat',
                        controller: beratController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: 
                       TextFieldWidget(
                          label: 'Ketebalan (mm)',
                          placeholder: 'Ketebalan',
                          controller: ketebalanController,
                        ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:   
                       TextFieldWidget(
                        label: 'Stok',
                        placeholder: 'Stok',
                        controller: stokController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          final productBloc =BlocProvider.of<ProductBloc>(context);
                          final Product newProduct = Product(
                            id: '', 
                            nama: namaController.text, 
                            deskripsi: deskripsiController.text, 
                            jenis: selectedJenis, 
                            satuan: selectedSatuan, 
                            berat: double.parse(beratController.text),
                            dimensi: int.parse(dimensiController.text), 
                            harga: int.parse(hargaController.text), 
                            ketebalan: int.parse(ketebalanController.text), 
                            status: selectedStatus == 'Aktif' ? 1 : 0, 
                            stok: int.parse(stokController.text)
                            );
                            if(widget.productId!=null){
                              productBloc.add(UpdateProductEvent(widget.productId ?? '',newProduct));
                            }else{
                              productBloc.add(AddProductEvent(newProduct));
                            }
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
                          stokController.clear();
                          selectedJenis = "Gelas Pop";
                          selectedSatuan = "Kg";
                          selectedStatus = "Aktif";
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
                 BlocBuilder<ProductBloc, ProductBlocState>(
                  builder: (context, state) {
                    if (state is ErrorState) {
                       Text(state.errorMessage);
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
