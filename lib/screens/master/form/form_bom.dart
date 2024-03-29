import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/billofmaterial.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/detail_billofmaterial.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardBahanWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormMasterBOMScreen extends StatefulWidget {
  static const routeName = '/master/bom/form';
  final String? bomId; // Terima ID pelanggan jika dalam mode edit
  final String? productId;

  const FormMasterBOMScreen({Key? key, this.bomId, this.productId})
      : super(key: key);

  @override
  State<FormMasterBOMScreen> createState() => _FormMasterBOMScreenState();
}

class _FormMasterBOMScreenState extends State<FormMasterBOMScreen> {
  String? selectedKodeProduk;
  String selectedStatus = "Aktif";
  DateTime? selectedDate;
  String? dropdownValue;
  bool isLoading = false;

  TextEditingController kodeBOMController = TextEditingController();
  TextEditingController namaProdukController = TextEditingController();
  TextEditingController dimensiControler = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController ketebalanController = TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController versiBOMController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  List<Map<String, dynamic>> productDataBahan = []; // Inisialisasi daftar bahan
  List<ProductCardDataBahan> productCards = [];
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final bomBloc = BillOfMaterialBloc();

  @override
  void dispose() {
    bomBloc.close();
    super.dispose();
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
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int bomCount = 1;

    while (true) {
      final nextBomId = 'BOM${bomCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextBomId)) {
        return nextBomId;
      }
      bomCount++;
    }
  }

  void fetchDataBahan() {
    // Ambil data produk dari Firestore di initState
    Query collectionQuery = firestore.collection('materials');

    if (widget.bomId == null) {
      // Jika widget.bomId == null, tambahkan klausa where status = 1
      collectionQuery = collectionQuery.where('status', isEqualTo: 1);
    }

    collectionQuery.get().then((querySnapshot) {
      List<Map<String, dynamic>> tempProductData =
          []; // Daftar sementara untuk penyimpanan data

      for (var doc in querySnapshot.docs) {
        String materialId = doc['id'];

        // Tambahkan pemeriksaan untuk mengabaikan material dengan ID "materialXXX"
        Map<String, dynamic> bahan = {
          'id': materialId, // Gunakan ID dokumen sebagai ID produk
          'nama': doc['nama']
              as String, // Ganti 'nama' dengan field yang sesuai di Firestore
        };

        tempProductData.add(bahan); // Tambahkan produk ke daftar sementara
      }

      // Urutkan daftar produk berdasarkan ID secara ascending
      tempProductData.sort((a, b) => a['id'].compareTo(b['id']));

      setState(() {
        productDataBahan =
            tempProductData; // Setel daftar produk ke daftar terurut
      });
    });
  }

  void addOrUpdateData() {
    final _bomBloc = BlocProvider.of<BillOfMaterialBloc>(context);

    final billOfMaterial = BillOfMaterial(
        id: '',
        productId: selectedKodeProduk ?? '',
        statusBOM: selectedStatus == 'Aktif' ? 1 : 0,
        tanggalPembuatan: selectedDate ?? DateTime.now(),
        versiBOM: 0,
        detailBOMList: [],
        status: 1);

    // Loop melalui productCards untuk menambahkan detail customer order
    for (var productCardData in productCards) {
      int jumlah = 0;
      if (productCardData.jumlah.isNotEmpty) {
        jumlah = int.tryParse(productCardData.jumlah) ?? 0;
      }

      final detailBOM = BomDetail(
        bomId: '',
        id: '',
        jumlah: jumlah,
        materialId: productCardData.kodeBahan,
        batch: productCardData.namaBatch ?? '',
        satuan: productCardData.satuan,
        status: 1,
      );
      billOfMaterial.detailBOMList?.add(detailBOM);
    }

    try {
      if (widget.bomId != null) {
        _bomBloc
            .add(UpdateBillOfMaterialEvent(widget.bomId ?? '', billOfMaterial));
      } else {
        // Dispatch event untuk menambahkan customer order
        _bomBloc.add(AddBillOfMaterialEvent(billOfMaterial));
      }
    } catch (e) {
      // Tangani pengecualian di sini jika diperlukan
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
      Navigator.pop(context, null);
    });
  }

// Fungsi untuk mengambil data detail_customer_orders
  void fetchDataDetail() async {
    firestore
        .collection('bill_of_materials')
        .doc(widget.bomId!)
        .collection('detail_bill_of_materials')
        .get()
        .then((querySnapshot) async {
      List<ProductCardDataBahan> newProductCards = [];

      await Future.wait(querySnapshot.docs.map((doc) async {
        final detailData = doc.data();

        final bahanId = detailData['material_id'];
        final material = productDataBahan.firstWhere(
          (material) => material['id'] == bahanId,
          orElse: () => {'nama': 'Produk Tidak Ditemukan'},
        );

        final productCardData = ProductCardDataBahan(
          kodeBahan: detailData['material_id'] as String,
          namaBahan: material['id'] as String,
          namaBatch: detailData['batch'] as String,
          jumlah: detailData['jumlah'].toString(),
          satuan: detailData['satuan'] as String,
        );

        newProductCards.add(productCardData);
      }));

      setState(() {
        productCards = newProductCards;
      });
    });
  }

  void initializeProduct() {
    selectedKodeProduk = widget.productId;
    firestore
        .collection('products')
        .where('id',
            isEqualTo:
                selectedKodeProduk) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final productData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final namaProduk = productData['id'];
        namaProdukController.text = namaProduk ?? '';
        ketebalanController.text = productData['ketebalan'].toString();
        dimensiControler.text = productData['dimensi'].toString();
        beratController.text = productData['berat'].toString();
        satuanController.text = productData['satuan'].toString();
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
    fetchDataBahan();

    // Panggil _generateNextBomId() dan isi kodeBOMController dengan hasilnya
    _initializeBomId();

    if (widget.bomId != null) {
      _fetchBomData();
    }

    if (widget.productId != null) {
      _initializeProductAndData();
    }
  }

  Future<void> _initializeBomId() async {
    final nextBomId = await _generateNextBomId();
    kodeBOMController.text = nextBomId;
  }

  void _fetchBomData() {
    firestore
        .collection('bill_of_materials')
        .doc(widget.bomId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      try {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            kodeBOMController.text = data['id'];
            versiBOMController.text = data['versi_bom'].toString();
            selectedStatus = data['status_bom'] == 1 ? 'Aktif' : 'Tidak Aktif';
            final tanggalPembuatanFirestore = data['tanggal_pembuatan'];
            if (tanggalPembuatanFirestore != null) {
              selectedDate = (tanggalPembuatanFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      } catch (error) {
        print('Error while processing document: $error');
        // Handle error as needed, e.g., show an error message to the user.
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  void _initializeProductAndData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeProduct();
      fetchDataDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillOfMaterialBloc, BillOfMaterialBlocState>(
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
              isLoading = true;
            });
          }
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
                                  child: Icon(Icons.arrow_back,
                                      color: Colors.black),
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
                        ProdukDropDown(
                          namaProdukController: namaProdukController,
                          versionController: versiBOMController,
                          dimensiControler: dimensiControler,
                          beratController: beratController,
                          ketebalanController: ketebalanController,
                          satuanController: satuanController,
                          selectedKode: selectedKodeProduk,
                          isEnabled: widget.bomId == null,
                          onChanged: (newValue) {
                            setState(() {
                              selectedKodeProduk = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWidget(
                          label: 'Kode Produk',
                          placeholder: 'Kode Produk',
                          controller: namaProdukController,
                          isEnabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Dimensi',
                                placeholder: 'Dimensi',
                                controller: dimensiControler,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Berat',
                                placeholder: 'Berat',
                                controller: beratController,
                                isEnabled: false,
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
                              child: TextFieldWidget(
                                label: 'Ketebalan',
                                placeholder: 'Ketebalan',
                                controller: ketebalanController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Satuan',
                                placeholder: 'Satuan ',
                                controller: satuanController,
                                isEnabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        DatePickerButton(
                          label: 'Tanggal Pembuatan BOM',
                          selectedDate: selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              selectedDate = newDate;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Versi BOM',
                          placeholder: '1',
                          controller: versiBOMController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        DropdownWidget(
                          label: 'Status BOM',
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
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
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
                                ProductCardBahanWidget(
                                  productCardData: productCardData,
                                  productCards: productCards,
                                  productData: productDataBahan,
                                ),
                              ],
                            );
                          }).toList(),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle save button press
                                  addOrUpdateData();
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
