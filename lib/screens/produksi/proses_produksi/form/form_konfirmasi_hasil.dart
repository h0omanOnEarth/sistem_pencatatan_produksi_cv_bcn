import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/class/productCardProductionResult.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/class/productCardProductionResultWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';


class FormKonfirmasiProduksiScreen extends StatefulWidget {
  static const routeName = '/form_konfirmasi_produksi_screen';
  final String? productionConfirmationId;

  const FormKonfirmasiProduksiScreen({Key? key, this.productionConfirmationId}) : super(key: key);
  
  
  @override
  State<FormKonfirmasiProduksiScreen> createState() =>
      _FormKonfirmasiProduksiScreenState();
}


class _FormKonfirmasiProduksiScreenState extends State<FormKonfirmasiProduksiScreen> {
  DateTime? selectedDate;


  List<ProductCardDataProductionResult> productCards = [];
  List<Map<String, dynamic>> productDataPR = []; // Inisialisasi daftar bahan

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  TextEditingController catatanController = TextEditingController();
  TextEditingController statusController = TextEditingController();

    void addProductCard() {
    setState(() {
      productCards.add(ProductCardDataProductionResult(
        nomorHasilProduksi: '',
        kodeBarang: '',
        namaBarang: '',
        jumlahHasil: '',
        satuan: '',
        jumlahKonfirmasi: '',
      ));
    });
  }

  void fetchDataProductionResult(){
    // Ambil data produk dari Firestore di initState
    firestore.collection('production_results').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> pResult = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
          'satuan': doc['satuan'] as String, // Ganti 'nama' dengan field yang sesuai di Firestore
          'jumlahHasil' : doc['total_produk'] as int,
          'materialUsageId' : doc['material_usage_id'] as String
        };
        setState(() {
          productDataPR.add(pResult); // Tambahkan produk ke daftar produk
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    addProductCard(); // Tambahkan product card secara default pada initState
    fetchDataProductionResult();
    statusController.text = "Dalam Proses";
  }

  void clear() {
  setState(() {
    selectedDate = null;
    catatanController.clear();
    statusController.text = "Dalam Proses";
    productCards.clear();
    addProductCard(); // Tambahkan kembali product card secara default
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Flexible(
                        child: Text(
                          'Konfirmasi Produksi',
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
                      label: 'Tanggal Pencatatan',
                      selectedDate: selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  controller: statusController,
                  isEnabled: false,
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
                      'Detail Konfirmasi',
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
                    ProductCardProductionResultWidget(productCardData: productCardData,productCards: productCards,productData: productDataPR, ),
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
                          clear();
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
    );
  }
}


