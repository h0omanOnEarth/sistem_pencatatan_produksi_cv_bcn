import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/billofmaterial.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/detail_billofmaterial.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardBahanWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';


class FormMasterBOMScreen extends StatefulWidget {
  static const routeName = '/form_master_bom_screen';
  final String? bomId; // Terima ID pelanggan jika dalam mode edit
  final String? productId;

  const FormMasterBOMScreen({Key?key, this.bomId, this.productId}): super(key: key);
  
  @override
  State<FormMasterBOMScreen> createState() =>
      _FormMasterBOMScreenState();
}


class _FormMasterBOMScreenState extends State<FormMasterBOMScreen> {
  String? selectedKodeProduk;
  String selectedStatus = "Aktif";
  DateTime? selectedDate;
  String? dropdownValue;

  TextEditingController kodeBOMController = TextEditingController();
  TextEditingController namaProdukController = TextEditingController();
  TextEditingController dimensiControler = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController ketebalanController =TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController versiBOMController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  List<Map<String, dynamic>> productDataBahan = []; // Inisialisasi daftar bahan
  List<ProductCardDataBahan> productCards = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  final bomBloc = BillOfMaterialBloc();

   @override
  void dispose() {
    bomBloc.close();
    selectedProdukNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKodeProduk = selectedProdukNotifier.value;
    });
  }
    
    void addProductCard() {
    setState(() {
      productCards.add(ProductCardDataBahan(
        kodeBahan: '',
        namaBahan: '',
        namaBatch: '',
        jumlah: '',
        satuan: '',
      ));
    });
  }

  Future<String> _generateNextBomId() async {
    final bomsRef = firestore.collection('bill_of_materials');
    final QuerySnapshot snapshot = await bomsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int bomCount = 1;

    while (true) {
      final nextBomId = 'BOM${bomCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextBomId)) {
        return nextBomId;
      }
      bomCount++;
    }
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

 void addOrUpdateData() {
  final _bomBloc = BlocProvider.of<BillOfMaterialBloc>(context);
  try {
    final billOfMaterial = BillOfMaterial(
      id: '',
      productId: selectedKodeProduk ?? '',
      statusBOM: selectedStatus == 'Aktif' ? 1 : 0,
      tanggalPembuatan: selectedDate ?? DateTime.now(),
      versiBOM: 0,
      detailBOMList: []
    );

    // Loop melalui productCards untuk menambahkan detail customer order
  for (var productCardData in productCards) {
    int jumlah = 0;
    if (productCardData.jumlah.isNotEmpty) {
      try {
        jumlah = int.parse(productCardData.jumlah);
      } catch (e) {
        print('Error parsing jumlah: $e');
        // Handle error parsing jika diperlukan
      }
    }

    final detailBOM = BomDetail(
      bomId: '',
      id: '',
      jumlah: jumlah,
      materialId: productCardData.kodeBahan,
      batch: productCardData.namaBatch??'',
      satuan: productCardData.satuan,
      status: 1,
    );
    billOfMaterial.detailBOMList?.add(detailBOM);
  }

  if (widget.bomId != null) {
    _bomBloc.add(UpdateBillOfMaterialEvent(widget.bomId ?? '', billOfMaterial));
  } else {
    // Dispatch event untuk menambahkan customer order
    _bomBloc.add(AddBillOfMaterialEvent(billOfMaterial));
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
      message: 'Berhasil menyimpan BOM.',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}

// Fungsi untuk mengambil data detail_customer_orders
void fetchDataDetail() {
  firestore
      .collection('bill_of_materials')
      .doc(widget.bomId!) // Menggunakan widget.bomId
      .collection('detail_bill_of_materials') 
      .get()
      .then((querySnapshot) {
    final newProductCards = <ProductCardDataBahan>[];
    querySnapshot.docs.forEach((doc) async {
      final detailData = doc.data() as Map<String, dynamic>;

      final bahanId = detailData['material_id'] as String;
      // Mencari nama produk berdasarkan productId
      final material = productDataBahan.firstWhere(
        (material) => material['id'] == bahanId,
        orElse: () => {'nama': 'Produk Tidak Ditemukan'}, // Default jika tidak ditemukan
      );

      final productCardData = ProductCardDataBahan(kodeBahan: detailData['material_id'] as String, namaBahan: material['nama'] as String, namaBatch: detailData['batch'] as String, jumlah: detailData['jumlah'].toString(), satuan: detailData['satuan'] as String);

      newProductCards.add(productCardData);
    });

    setState(() {
      productCards = newProductCards;
    });
  });
}

void initializeProduct(){
    selectedKodeProduk = widget.productId;
    _selectedKodeListener();
    firestore
    .collection('products')
    .where('id', isEqualTo: selectedKodeProduk) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) {
    if (querySnapshot.docs.isNotEmpty) {
      final productData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final namaProduk = productData['nama'];
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
  addProductCard();
  selectedProdukNotifier.addListener(_selectedKodeListener);
  selectedKodeProduk = selectedProdukNotifier.value;
  fetchDataBahan();
   // Panggil _generateNextBomId() dan isi kodeBOMController dengan hasilnya
  _generateNextBomId().then((nextBomId) {
    kodeBOMController.text = nextBomId;
  });

  if (widget.bomId != null) {
    // Jika ada customerOrderId, ambil data dari Firestore
       firestore
        .collection('bill_of_materials')
        .doc(widget.bomId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          kodeBOMController.text = data['id'];
          versiBOMController.text = data['versi_bom'].toString();
          selectedStatus = data['status_bom'] == 1 ? 'Aktif' : 'Tidak Aktif';;
          final tanggalPembuatanFirestore = data['tanggal_pembuatan'];
          if (tanggalPembuatanFirestore != null) {
            selectedDate = (tanggalPembuatanFirestore as Timestamp).toDate();
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

  if(widget.productId!=null){
    initializeProduct();
  }

}

  @override
  Widget build(BuildContext context) {   
    return BlocProvider(
    create: (context) => BillOfMaterialBloc(),
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
                    const Text(
                      'Bill of Material',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Kode BOM',
                  placeholder: 'Kode BOM',
                  controller: kodeBOMController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0),
                ProdukDropDown(namaProdukController: namaProdukController,versionController: versiBOMController, dimensiControler: dimensiControler, beratController: beratController, ketebalanController: ketebalanController,satuanController: satuanController, productId: widget.productId,),
                const SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Nama Produk',
                  placeholder: 'Nama Produk',
                  controller: namaProdukController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: 
                    TextFieldWidget(
                      label: 'Dimensi',
                      placeholder: 'Dimensi',
                      controller: dimensiControler,
                      isEnabled: false,
                    ),),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Berat',
                        placeholder: 'Berat',
                        controller: beratController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(child: 
                       TextFieldWidget(
                          label: 'Ketebalan',
                          placeholder: 'Ketebalan',
                          controller: ketebalanController,
                          isEnabled: false,
                        ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child:   
                       TextFieldWidget(
                        label: 'Satuan',
                        placeholder: 'Satuan ',
                        controller: satuanController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),    
                const SizedBox(height: 16.0,),
                DatePickerButton(
                      label: 'Tanggal Pembuatan BOM',
                      selectedDate: selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Versi BOM',
                  placeholder: '1',
                  controller: versiBOMController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0,),
                DropdownWidget(
                  label: 'Status BOM',
                  selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                  items: const ['Aktif', 'Tidak Aktif'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                      print('Selected value: $newValue');
                    });
                  },
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
                    'Detail Bahan',
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
                          addOrUpdateData();
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


