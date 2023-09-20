import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_usage_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_usage.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_usage.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardBahanWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_request_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionorder_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenggunaanBahanScreen extends StatefulWidget {
  static const routeName = '/form_penggunaan_bahan_screen';
  final String? materialUsageId;
  final String? productionOrderId;

  const FormPenggunaanBahanScreen({Key? key, this.materialUsageId, this.productionOrderId}) : super(key: key);
  
  @override
  State<FormPenggunaanBahanScreen> createState() =>
      _FormPenggunaanBahanScreenState();
}


class _FormPenggunaanBahanScreenState extends State<FormPenggunaanBahanScreen> {
  String? selectedNomorPerintah;
  String? selectedNomorPermintaan;
  String selectedKodeBatch = "Pencampuran";
  DateTime? selectedDate;

  TextEditingController catatanController = TextEditingController();
  TextEditingController kodeProdukController = TextEditingController();
  TextEditingController namaProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore

  List<ProductCardDataBahan> productCards = [];
  List<Map<String, dynamic>> productDataBahan = []; // Inisialisasi daftar bahan

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

// Fungsi untuk mengambil data detail_customer_orders
void fetchDataDetail() {
  firestore
      .collection('material_usages')
      .doc(widget.materialUsageId!) // Menggunakan widget.bomId
      .collection('detail_material_usages') 
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

Future<String?> getProductName(String productId) async {
  try {
    final productQuery = await firestore
        .collection('products')
        .where('id', isEqualTo: productId) // Ganti 'product_id' dengan nama field yang sesuai
        .limit(1) // Batasi hasil ke satu dokumen (jika ada banyak yang cocok)
        .get();

    if (productQuery.docs.isNotEmpty) {
      final productName = productQuery.docs.first['nama'] as String?;
      return productName;
    }
    return null;
  } catch (e) {
    print('Error fetching product name: $e');
    return null;
  }
}

void initializeProductionOrder(){
    selectedNomorPermintaan = widget.productionOrderId;
    firestore
    .collection('production_orders')
    .where('id', isEqualTo: selectedNomorPermintaan) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      final productData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      kodeProdukController.text = productData['product_id'];
      final namaProduk = await getProductName(productData['product_id']);;
      namaProdukController.text = namaProduk ?? '';
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
  statusController.text = "Dalam Proses";

  if (widget.materialUsageId != null) {
    // Jika ada customerOrderId, ambil data dari Firestore
       firestore
        .collection('material_usages')
        .doc(widget.materialUsageId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_mu'];
          selectedKodeBatch = data['batch'];
          final tanggalPenggunaanFirestore = data['tanggal_penggunaan'];
          if (tanggalPenggunaanFirestore != null) {
            selectedDate = (tanggalPenggunaanFirestore as Timestamp).toDate();
          }
          selectedNomorPermintaan = data['material_request_id'];
          selectedNomorPerintah = data['production_order_id'];
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });

     fetchDataDetail(); // Ambil data detail_customer_orders
  }

  if(widget.productionOrderId!=null){
    initializeProductionOrder();
  }
}

@override
void dispose() {
  super.dispose();
}

void clearForm() {
  setState(() {
    // Reset semua nilai yang ingin Anda bersihkan ke nilai awal atau kosong
    selectedNomorPerintah = null;
    selectedNomorPermintaan = null;
    selectedKodeBatch = "Pencampuran";
    selectedDate = null;
    catatanController.text = ""; // Mengosongkan catatan
    kodeProdukController.text = ""; // Mengosongkan kode produk
    namaProdukController.text = ""; // Mengosongkan nama produk
    productCards.clear(); // Menghapus semua product cards
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

void addOrUpdate(){
 final materialUsageBloc = BlocProvider.of<MaterialUsageBloc>(context);
  try {
    final materialUsage = MaterialUsage(batch: selectedKodeBatch, catatan: catatanController.text, id: '', productionOrderId: selectedNomorPerintah??'', status: 1, statusMu: statusController.text , tanggalPenggunaan: selectedDate??DateTime.now(), detailMaterialUsageList: [], materialRequestId: selectedNomorPermintaan??'');

    // Loop melalui productCards untuk menambahkan detail customer order
  for (var productCardData in productCards) {
    final detailMaterialUsage = DetailMaterialUsage(id: '', jumlah: int.parse(productCardData.jumlah), materialId: productCardData.kodeBahan, materialUsageId: '', satuan: productCardData.satuan, status: 1);
    materialUsage.detailMaterialUsageList.add(detailMaterialUsage);
  }

  if (widget.materialUsageId != null) {
    materialUsageBloc.add(UpdateMaterialUsageEvent(widget.materialUsageId ?? '', materialUsage));
  } else {
    // Dispatch event untuk menambahkan customer order
    materialUsageBloc.add(AddMaterialUsageEvent(materialUsage));
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
      message: 'Berhasil menyimpan penggunaan bahan.',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => MaterialUsageBloc(),
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
                        Navigator.pop(context,null);
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
                        'Penggunaan Bahan',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                ProductionOrderDropDown(selectedPRO: selectedNomorPerintah, onChanged: (newValue) {
                      setState(() {
                        selectedNomorPerintah = newValue??'';
                      });
                }, kodeProdukController: kodeProdukController, namaProdukController: namaProdukController,),
                const SizedBox(height: 16.0),
                MaterialRequestDropdown(selectedMaterialRequest: selectedNomorPermintaan,  onChanged: (newValue) {
                      setState(() {
                        selectedNomorPermintaan = newValue??'';
                      });
                }),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: 
                    TextFieldWidget(
                      label: 'Kode Produk',
                      placeholder: 'Kode Produk',
                      controller: kodeProdukController,
                      isEnabled: false,
                    ),),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Nama Produk',
                        placeholder: 'Nama Produk',
                        controller: namaProdukController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                DropdownWidget(
                      label: 'Kode Batch',
                      selectedValue: selectedKodeBatch, // Isi dengan nilai yang sesuai
                      items: const ['Pencampuran', 'Sheet', 'Pencetakan', 'Penggilingan'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedKodeBatch = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                ),
                const SizedBox(height: 16.0,),
                DatePickerButton(
                      label: 'Tanggal Penggunaan',
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
                  isEnabled: false,
                  controller: statusController,
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
                    'Detail Penggunaan',
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
                          clearForm();
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
    )
    );
  }
}



