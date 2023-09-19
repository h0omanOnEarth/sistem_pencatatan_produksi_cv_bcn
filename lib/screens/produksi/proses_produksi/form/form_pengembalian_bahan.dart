import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardBahanWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_usage_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPengembalianBahanScreen extends StatefulWidget {
  static const routeName = '/form_pengembalian_bahan_screen';
  final String? materialUsageId;
  final String? materialReturnId;

  const FormPengembalianBahanScreen({Key? key, this.materialUsageId, this.materialReturnId}) : super(key: key);
  
  @override
  State<FormPengembalianBahanScreen> createState() =>
      _FormPengembalianBahanScreenState();
}


class _FormPengembalianBahanScreenState extends State<FormPengembalianBahanScreen> {
  String? selectedNomorPenggunaan;
  DateTime? selectedDate;

  List<ProductCardDataBahan> productCards = [];
  List<Map<String, dynamic>> productDataBahan = []; // Inisialisasi daftar bahan

  TextEditingController catatanController = TextEditingController();
  TextEditingController namaBatchController = TextEditingController();
  TextEditingController statusController =  TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore

    void addProductCard() {
    setState(() {
      productCards.add(ProductCardDataBahan(
        kodeBahan: '',
        namaBahan: '',
        jumlah: '',
        satuan: '',
      ));
    });
  }

  void fetchDataBahan(){
  // Ambil data produk dari Firestore di initState
  firestore.collection('materials').get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> bahan = {
        'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
        'nama': doc['nama'] as String, // Ganti 'nama' dengan field yang sesuai di Firestore
      };
      setState(() {
        productDataBahan.add(bahan); // Tambahkan produk ke daftar produk
      });
    });
  });
}

void fetchDataDetail() {
  firestore
      .collection('material_returns')
      .doc(widget.materialReturnId!) // Menggunakan widget.bomId
      .collection('detail_material_returns') 
      .get()
      .then((querySnapshot) {
    final newProductCards = <ProductCardDataBahan>[];
    querySnapshot.docs.forEach((doc) async {
      final detailData = doc.data();

      final bahanId = detailData['material_id'] as String;
      // Mencari nama produk berdasarkan productId
      final material = productDataBahan.firstWhere(
        (material) => material['id'] == bahanId,
        orElse: () => {'nama': 'Produk Tidak Ditemukan'}, // Default jika tidak ditemukan
      );

      final productCardData = ProductCardDataBahan(kodeBahan: detailData['material_id'] as String, namaBahan: material['nama'] as String, jumlah: detailData['jumlah'].toString(), satuan: detailData['satuan'] as String);

      newProductCards.add(productCardData);
    });

    setState(() {
      productCards = newProductCards;
    });
  });
}

void clearForm() {
  setState(() {
    selectedNomorPenggunaan = null;
    selectedDate = null;
    productCards.clear();
    namaBatchController.clear();
    catatanController.clear();
    statusController.text = "Dalam Proses";
  });
}

void initializeMaterialUsage(){
    selectedNomorPenggunaan = widget.materialUsageId;
    firestore
    .collection('material_usages')
    .where('id', isEqualTo: selectedNomorPenggunaan) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      final productData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      namaBatchController.text = productData['batch'];
    } else {
      print('Document does not exist on Firestore');
    }
  }).catchError((error) {
    print('Error getting document: $error');
  });
}

  @override
  void initState() {
    super.initState();
    addProductCard(); // Tambahkan product card secara default pada initState
    fetchDataBahan();
    statusController.text ="Dalam Proses";

    if (widget.materialReturnId != null) {
    // Jika ada customerOrderId, ambil data dari Firestore
       firestore
        .collection('material_returns')
        .doc(widget.materialReturnId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_mrt'];
          selectedNomorPenggunaan = data['material_usage_id'];
          final tanggalPengembalianFirestore = data['tanggal_pengembalian'];
          if (tanggalPengembalianFirestore != null) {
            selectedDate = (tanggalPengembalianFirestore as Timestamp).toDate();
          }
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });

     fetchDataDetail(); // Ambil data detail_customer_orders
  }

  if(widget.materialUsageId!=null){
    initializeMaterialUsage();
  }
  }

  void addOrUpdate(){
    final materialReturnBloc = BlocProvider.of<MaterialReturnBloc>(context);
      try {
        final materialReturn = MaterialReturn(id: '', materialUsageId: selectedNomorPenggunaan??'', catatan: catatanController.text, status: 1, statusMrt: statusController.text, tanggalPengembalian: selectedDate??DateTime.now(), detailMaterialReturn: []);

        // Loop melalui productCards untuk menambahkan detail customer order
      for (var productCardData in productCards) {
        final detailMaterialReturn = MaterialReturnDetail(id: '', jumlah: productCardData.jumlah, materialId: productCardData.kodeBahan, materialReturnId: '', satuan: productCardData.satuan, status: 1);
        materialReturn.detailMaterialReturn.add(detailMaterialReturn);
      }

      if (widget.materialReturnId != null) {
        materialReturnBloc.add(UpdateMaterialReturnEvent(widget.materialReturnId??'', materialReturn));
      } else {
        // Dispatch event untuk menambahkan customer order
        materialReturnBloc.add(AddMaterialReturnEvent(materialReturn));
      }

      _showSuccessMessageAndNavigateBack();
    } catch (e) {
      // Tangani pengecualian di sini
      print('Error: $e');
    }
  }

  
void _showSuccessMessageAndNavigateBack() {
showDialog(
  context: context,
  builder: (BuildContext context) {
    return SuccessDialog(
      message: 'Berhasil menyimpan pengembalian bahan.',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => MaterialReturnBloc(),
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
                    const Flexible(
                        child: Text(
                          'Pengembalian Bahan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                DatePickerButton(
                      label: 'Tanggal Pengembalian',
                      selectedDate: selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                ),
                const SizedBox(height: 16.0,),
                MaterialUsageDropdown(selectedMaterialUsage: selectedNomorPenggunaan, onChanged: (newValue) {
                      setState(() {
                        selectedNomorPenggunaan = newValue??'';
                      });
                }, namaBatchController: namaBatchController,),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Nama Batch',
                  placeholder: 'Nama Batch',
                  controller: namaBatchController,
                  isEnabled: false,
                ),          
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  isEnabled: false,
                  controller: statusController
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                ),
                const SizedBox(height: 16.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Pengembalian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      addProductCard();
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
               if (productCards.isNotEmpty)
              ...productCards.map((productCardData) {
                return ProductCard(
                  productCardData: productCardData,
                  onDelete: () {
                    setState(() {
                      productCards.remove(productCardData);
                    });
                  },
                  children: [
                    ProductCardBahanWidget(productCardData: productCardData,productCards: productCards,productData: productDataBahan, ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          addOrUpdate();
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
                          clearForm();
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
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}


