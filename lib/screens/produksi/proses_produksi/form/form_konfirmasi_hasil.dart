import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_confirmation_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_production_confirmation.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_confirmation.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/class/productCardProductionResult.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/class/productCardProductionResultWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productionOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormKonfirmasiProduksiScreen extends StatefulWidget {
  static const routeName = '/produksi/proses/konfirmasi/form';
  final String? productionConfirmationId;
  final String? statusPrc;

  const FormKonfirmasiProduksiScreen(
      {Key? key, this.productionConfirmationId, this.statusPrc})
      : super(key: key);

  @override
  State<FormKonfirmasiProduksiScreen> createState() =>
      _FormKonfirmasiProduksiScreenState();
}

class _FormKonfirmasiProduksiScreenState
    extends State<FormKonfirmasiProduksiScreen> {
  DateTime? selectedDate;
  bool isLoading = false;

  List<ProductCardDataProductionResult> productCards = [];
  List<Map<String, dynamic>> productDataPR = []; // Inisialisasi daftar bahan

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final productionOrderService = ProductionOrderService();
  TextEditingController catatanController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController totalController = TextEditingController();

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
      updateTotal();
    });
  }

  void updateTotal() {
    int total = 0;
    for (var productCardData in productCards) {
      if (productCardData.jumlahKonfirmasi.isNotEmpty) {
        int subtotalValue = int.tryParse(productCardData.jumlahKonfirmasi) ?? 0;
        total += subtotalValue;
      }
    }
    setState(() {
      totalController.text = total.toString(); // Format total harga
    });
  }

  void fetchDataProductionResult() {
    Query collection = firestore.collection('production_results');

    // Periksa apakah widget.productionConfirmationId adalah null
    if (widget.productionConfirmationId == null) {
      collection = collection.where('status_prs', isEqualTo: 'Dalam Proses');
    }

    collection.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> pResult = {
          'id': doc['id'],
          'satuan': doc['satuan'] as String,
          'jumlahHasil': doc['jumlah_produk_berhasil'] as int,
          'materialUsageId': doc['material_usage_id'] as String
        };
        setState(() {
          productDataPR.add(pResult);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchDataDetail() {
    firestore
        .collection('production_confirmations')
        .doc(widget.productionConfirmationId!)
        .collection('detail_production_confirmations')
        .get()
        .then((querySnapshot) async {
      final newProductCards = <ProductCardDataProductionResult>[];
      for (var doc in querySnapshot.docs) {
        final detailData = doc.data();
        final productionResultId = detailData['production_result_id'] as String;
        final productionResult = productDataPR.firstWhere(
          (pResult) => pResult['id'] == productionResultId,
          orElse: () => {'nama': 'Hasil Produksi Tidak Ditemukan'},
        );

        String productName =
            'Produk Tidak Ditemukan'; // Default jika produk tidak ditemukan
        Map<String, dynamic>? product = await productionOrderService
            .getProductInfo(detailData['product_id']);
        if (product != null && product.containsKey('product_name')) {
          productName = product['product_name'] as String;
        }

        final productCardData = ProductCardDataProductionResult(
          nomorHasilProduksi: productionResult['id'] as String,
          kodeBarang: detailData['product_id'] as String,
          namaBarang: productName,
          jumlahHasil: productionResult['jumlahHasil'].toString(),
          satuan: productionResult['satuan'] as String,
          jumlahKonfirmasi: detailData['jumlah_konfirmasi'].toString(),
        );

        newProductCards.add(productCardData);
      }

      setState(() {
        productCards = newProductCards;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    addProductCard(); // Tambahkan product card secara default pada initState
    fetchDataProductionResult();
    statusController.text = "Dalam Proses";

    if (widget.productionConfirmationId != null) {
      firestore
          .collection('production_confirmations')
          .doc(widget
              .productionConfirmationId) // Menggunakan widget.customerOrderId
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_prc'] ?? '';
            totalController.text = data['total'].toString();
            final tanggalKonfirmasiFirestore = data['tanggal_konfirmasi'];
            if (tanggalKonfirmasiFirestore != null) {
              selectedDate = (tanggalKonfirmasiFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
    if (widget.productionConfirmationId != null) {
      fetchDataDetail();
    }
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

  void addOrUpdate() {
    try {
      final proConfBloc = BlocProvider.of<ProductionConfirmationBloc>(context);
      final proConf = ProductionConfirmation(
          id: '',
          catatan: catatanController.text,
          status: 1,
          statusPrc: statusController.text,
          tanggalKonfirmasi: selectedDate ?? DateTime.now(),
          detailProductionConfirmations: [],
          total: int.tryParse(totalController.text) ?? 0);
      // Loop melalui productCards untuk menambahkan detail customer order
      for (var productCardData in productCards) {
        final detailProductionCon = DetailProductionConfirmation(
            id: '',
            jumlahKonfirmasi:
                int.tryParse(productCardData.jumlahKonfirmasi) ?? 0,
            productionConfirmationId: '',
            productionResultId: productCardData.nomorHasilProduksi,
            satuan: productCardData.satuan,
            productId: productCardData.kodeBarang,
            status: 1);
        proConf.detailProductionConfirmations.add(detailProductionCon);
      }

      if (widget.productionConfirmationId != null) {
        proConfBloc.add(UpdateProductionConfirmationEvent(
            widget.productionConfirmationId ?? '', proConf));
      } else {
        proConfBloc.add(AddProductionConfirmationEvent(proConf));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan konfirmasi produksi.',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductionConfirmationBloc,
            ProductionConfirmationBlocState>(
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
                                'Konfirmasi Produksi',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        DatePickerButton(
                            label: 'Tanggal Pencatatan',
                            selectedDate: selectedDate,
                            onDateSelected: (newDate) {
                              setState(() {
                                selectedDate = newDate;
                              });
                            },
                            isEnabled: widget.statusPrc != "Selesai"),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Total',
                                placeholder: '0',
                                controller: totalController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            const Expanded(
                              child: TextFieldWidget(
                                label: '',
                                placeholder: 'Pcs',
                                isEnabled: false,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Status',
                          placeholder: 'Dalam Proses',
                          controller: statusController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                            label: 'Catatan',
                            placeholder: 'Catatan',
                            controller: catatanController,
                            isEnabled: widget.statusPrc != "Selesai"),
                        const SizedBox(
                          height: 24.0,
                        ),
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
                            if (widget.productionConfirmationId == null)
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
                                  updateTotal();
                                });
                              },
                              isEnabled:
                                  widget.productionConfirmationId == null,
                              children: [
                                ProductCardProductionResultWidget(
                                  productCardData: productCardData,
                                  productCards: productCards,
                                  productData: productDataPR,
                                  isEnabled:
                                      widget.productionConfirmationId == null,
                                  updateTotal: updateTotal,
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
                                onPressed: widget.statusPrc == "Selesai"
                                    ? null
                                    : () {
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
                                onPressed: widget.statusPrc == "Selesai"
                                    ? null
                                    : () {
                                        clear();
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
