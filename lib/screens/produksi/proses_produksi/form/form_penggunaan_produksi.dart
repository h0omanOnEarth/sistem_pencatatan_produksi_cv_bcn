import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_usage_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_usage.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_usage.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardBahanWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_request_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionorder_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenggunaanBahanScreen extends StatefulWidget {
  static const routeName = '/produksi/proses/penggunaan/form';
  final String? materialUsageId;
  final String? productionOrderId;
  final String? materialRequestId;
  final String? statusMu;

  const FormPenggunaanBahanScreen(
      {Key? key,
      this.materialUsageId,
      this.productionOrderId,
      this.materialRequestId,
      this.statusMu})
      : super(key: key);

  @override
  State<FormPenggunaanBahanScreen> createState() =>
      _FormPenggunaanBahanScreenState();
}

class _FormPenggunaanBahanScreenState extends State<FormPenggunaanBahanScreen> {
  String? selectedNomorPerintah;
  String? selectedNomorPermintaan;
  String selectedKodeBatch = "Pencampuran";
  DateTime? selectedDate;
  bool isLoading = false;

  TextEditingController catatanController = TextEditingController();
  TextEditingController kodeProdukController = TextEditingController();
  TextEditingController namaProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

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
          orElse: () => {
            'nama': 'Produk Tidak Ditemukan'
          }, // Default jika tidak ditemukan
        );

        final productCardData = ProductCardDataBahan(
            kodeBahan: detailData['material_id'] as String,
            namaBahan: material['nama'] as String,
            jumlah: detailData['jumlah'].toString(),
            satuan: detailData['satuan'] as String);

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
          .where('id', isEqualTo: productId)
          .limit(1)
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

  Future<void> filterProductDataBahan(String materialRequestId) async {
    final List<Map<String, dynamic>> filteredProductDataBahan = [];

    if (materialRequestId.isNotEmpty) {
      final detailMaterialRequestsQuery = await firestore
          .collection('material_requests')
          .doc(materialRequestId)
          .collection('detail_material_requests')
          .get();

      final detailMaterialRequests =
          detailMaterialRequestsQuery.docs.map((doc) => doc.data());

      for (final detailMaterialRequest in detailMaterialRequests) {
        final materialId = detailMaterialRequest['material_id'] as String;

        // Lakukan filter berdasarkan material_id
        final filteredData = productDataBahan.where((product) {
          final productMaterialId = product['id'] as String;
          return productMaterialId == materialId;
        }).toList();

        filteredProductDataBahan.addAll(filteredData);
      }
    }

    setState(() {
      productDataBahan = filteredProductDataBahan;
    });
  }

  void initializeProductionOrder() {
    selectedNomorPerintah = widget.productionOrderId;
    firestore
        .collection('production_orders')
        .where('id',
            isEqualTo:
                selectedNomorPerintah) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        final productData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        kodeProdukController.text = productData['product_id'];
        final namaProduk = await getProductName(productData['product_id']);
        ;
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
            statusController.text = data['status_mu'] ?? '';
            selectedKodeBatch = data['batch'] ?? '';
            final tanggalPenggunaanFirestore = data['tanggal_penggunaan'];
            if (tanggalPenggunaanFirestore != null) {
              selectedDate = (tanggalPenggunaanFirestore as Timestamp).toDate();
            }
            selectedNomorPermintaan = data['material_request_id'] ?? '';
            selectedNomorPerintah = data['production_order_id'] ?? '';
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.productionOrderId != null) {
      initializeProductionOrder();
    }

    if (widget.materialRequestId != null) {
      filterProductDataBahan(widget.materialRequestId ?? '');
      fetchDataDetail();
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
      productDataBahan.clear();
      addProductCard();
      fetchDataBahan();
    });
  }

  void resetProductCardDropdown(String newValue) {
    productCards.clear();
    productDataBahan.clear();
    addProductCard();
    fetchDataBahan();
    filterProductDataBahan(newValue);
  }

  void fetchDataBahan() {
    // Ambil data produk dari Firestore di initState
    Query collectionQuery = firestore.collection('materials');

    // Jika widget.materialUsageId == null atau ID material adalah "materialXXX", tambahkan klausa where status = 1
    if (widget.materialUsageId == null) {
      // collectionQuery = collectionQuery.where('status', isEqualTo: 1);
      collectionQuery =
          collectionQuery; //logikanya kalau sudah terlanjur terdaftar di bom gimana lagi, berlaku juga untuk pengembalian bahan
    }

    collectionQuery.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String materialId = doc['id'];

        // Tambahkan pemeriksaan untuk mengabaikan material dengan ID "materialXXX"
        if (materialId != 'materialXXX') {
          Map<String, dynamic> bahan = {
            'id': materialId, // Gunakan ID dokumen sebagai ID produk
            'nama': doc['nama']
                as String, // Ganti 'nama' dengan field yang sesuai di Firestore
          };
          setState(() {
            productDataBahan.add(bahan); // Tambahkan produk ke daftar produk
          });
        }
      }
    });
  }

  void addOrUpdate() {
    final materialUsageBloc = BlocProvider.of<MaterialUsageBloc>(context);
    try {
      final materialUsage = MaterialUsage(
          batch: selectedKodeBatch,
          catatan: catatanController.text,
          id: '',
          productionOrderId: selectedNomorPerintah ?? '',
          status: 1,
          statusMu: statusController.text,
          tanggalPenggunaan: selectedDate ?? DateTime.now(),
          detailMaterialUsageList: [],
          materialRequestId: selectedNomorPermintaan ?? '');

      // Loop melalui productCards untuk menambahkan detail customer order
      for (var productCardData in productCards) {
        final detailMaterialUsage = DetailMaterialUsage(
            id: '',
            jumlah: int.tryParse(productCardData.jumlah) ?? 0,
            materialId: productCardData.kodeBahan,
            materialUsageId: '',
            satuan: productCardData.satuan,
            status: 1);
        materialUsage.detailMaterialUsageList.add(detailMaterialUsage);
      }

      if (widget.materialUsageId != null) {
        materialUsageBloc.add(UpdateMaterialUsageEvent(
            widget.materialUsageId ?? '', materialUsage));
      } else {
        // Dispatch event untuk menambahkan customer order
        materialUsageBloc.add(AddMaterialUsageEvent(materialUsage));
      }
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
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialUsageBloc, MaterialUsageBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false;
            });
          } else if (state is ErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            ).then((_) {
              Navigator.pop(context, null);
            });
            ;
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
                        ProductionOrderDropDown(
                          selectedPRO: selectedNomorPerintah,
                          onChanged: (newValue) {
                            setState(() {
                              selectedNomorPerintah = newValue ?? '';
                            });
                          },
                          kodeProdukController: kodeProdukController,
                          namaProdukController: namaProdukController,
                          isEnabled: widget.materialUsageId == null,
                        ),
                        const SizedBox(height: 16.0),
                        MaterialRequestDropdown(
                            selectedMaterialRequest: selectedNomorPermintaan,
                            onChanged: (newValue) {
                              setState(() {
                                selectedNomorPermintaan = newValue ?? '';
                                if (productCards[0].kodeBahan.isNotEmpty) {
                                  resetProductCardDropdown(newValue ?? '');
                                } else {
                                  productDataBahan.clear();
                                  fetchDataBahan();
                                  filterProductDataBahan(newValue ?? '');
                                }
                              });
                            },
                            isEnabled: widget.materialUsageId == null),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Kode Produk',
                                placeholder: 'Kode Produk',
                                controller: kodeProdukController,
                                isEnabled: false,
                              ),
                            ),
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
                        const SizedBox(
                          height: 16.0,
                        ),
                        DropdownWidget(
                          label: 'Kode Batch',
                          selectedValue:
                              selectedKodeBatch, // Isi dengan nilai yang sesuai
                          items: const [
                            'Pencampuran',
                            'Sheet',
                            'Pencetakan',
                            'Penggilingan'
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              selectedKodeBatch =
                                  newValue; // Update _selectedValue saat nilai berubah
                            });
                          },
                          isEnabled: widget.statusMu != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        DatePickerButton(
                          label: 'Tanggal Penggunaan',
                          selectedDate: selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              selectedDate = newDate;
                            });
                          },
                          isEnabled: widget.materialUsageId != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Status',
                          placeholder: 'Dalam Proses',
                          isEnabled: false,
                          controller: statusController,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusMu != "Selesai",
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
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
                            if (widget.statusMu != "Selesai")
                              InkWell(
                                onTap: () {
                                  addProductCard();
                                },
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Color.fromRGBO(59, 51, 51, 1),
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
                              isEnabled: widget.statusMu != "Selesai",
                              children: [
                                ProductCardBahanWidget(
                                  productCardData: productCardData,
                                  productCards: productCards,
                                  productData: productDataBahan,
                                  isEnabled: widget.statusMu != "Selesai",
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
                                onPressed: widget.statusMu == "Selesai"
                                    ? null
                                    : () {
                                        // Handle save button press
                                        addOrUpdate();
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
                                onPressed: widget.statusMu == "Selesai"
                                    ? null
                                    : () {
                                        // Handle clear button press
                                        clearForm();
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
                    color: Colors.black
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
