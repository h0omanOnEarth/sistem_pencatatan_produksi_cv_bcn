import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/item_receive_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_item_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/item_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productionConfirmationService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionConfirmationWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenerimaanHasilProduksi extends StatefulWidget {
  static const routeName = '/gudang/produksi/penerimaan/form';
  final String? itemReceivceId;
  final String? productionConfirmationId;
  final String? statusIrc;

  const FormPenerimaanHasilProduksi(
      {Key? key,
      this.itemReceivceId,
      this.productionConfirmationId,
      this.statusIrc})
      : super(key: key);

  @override
  State<FormPenerimaanHasilProduksi> createState() =>
      _FormPenerimaanHasilProduksiState();
}

class _FormPenerimaanHasilProduksiState
    extends State<FormPenerimaanHasilProduksi> {
  DateTime? _selectedDate;
  String? selectedNomorKonfirmasi;
  bool isLoading = false;
  TextEditingController catatanController = TextEditingController();
  TextEditingController tanggalKonfirmasiController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  List<Map<String, dynamic>> materialDetailsData = []; // Initialize the list
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  final productService = ProductService();
  final productionCofirmationService = ProductionConfirmationService();
  List<Widget> customCards = [];

  Future<void> fetchConfirmations() async {
    QuerySnapshot snapshot;
    if (widget.itemReceivceId != null) {
      snapshot = await firestore
          .collection('item_receives')
          .doc(widget.itemReceivceId)
          .collection('detail_item_receives')
          .get();
    } else {
      snapshot = await firestore
          .collection('production_confirmations')
          .doc(selectedNomorKonfirmasi)
          .collection('detail_production_confirmations')
          .get();
    }

    customCards.clear();
    materialDetailsData.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['product_id'] as String? ?? '';

      Future<Map<String, dynamic>> productInfoFuture =
          productService.fetchProductInfo(productId);

      final productInfoSnapshot = await productInfoFuture;

      final productName = productInfoSnapshot['nama'] as String;
      final jumlahDusString =
          (data['jumlah_konfirmasi'] ~/ productInfoSnapshot['banyaknya'] as int)
              .toString();

      Map<String, dynamic> detailMaterial = {
        'productId': productId, // Add fields you need
        'jumlah': data['jumlah_konfirmasi'],
      };
      materialDetailsData.add(detailMaterial);

      final customCard = CustomCard(
        content: [
          CustomCardContent(text: 'Kode Barang: $productId'),
          CustomCardContent(text: 'Nama: $productName'),
          CustomCardContent(
              text: 'Jumlah Pcs: ${data['jumlah_konfirmasi'].toString()} Pcs'),
          CustomCardContent(text: 'Jumlah Dus: $jumlahDusString Dus'),
        ],
      );

      customCards.add(customCard);
    }
    setState(() {});
  }

  void initProductionConf() async {
    Map<String, dynamic>? productionConf = await productionCofirmationService
        .getProductionConfirmationInfo(widget.productionConfirmationId ?? '');
    var tanggalKonfirmasiFirestore = productionConf?['tanggalKonfirmasi'];
    String tanggalPermintaan = '';

    if (tanggalKonfirmasiFirestore != null) {
      final timestamp = tanggalKonfirmasiFirestore as Timestamp;
      final dateTime = timestamp.toDate();

      final List<String> monthNames = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember"
      ];

      final day = dateTime.day.toString();
      final month = monthNames[dateTime.month - 1];
      final year = dateTime.year.toString();

      tanggalPermintaan = '$day $month $year';
    }

    tanggalKonfirmasiController.text = tanggalPermintaan;
  }

  @override
  void initState() {
    super.initState();
    if (widget.itemReceivceId != null) {
      _initializeItemReceive();
    }

    if (widget.productionConfirmationId != null) {
      _initializeProductionConfirmation();
      fetchConfirmations();
    }
  }

  void _initializeItemReceive() {
    firestore
        .collection('item_receives')
        .doc(widget.itemReceivceId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_irc'];
          final tanggalPenerimaanFirestore = data['tanggal_penerimaan'];
          if (tanggalPenerimaanFirestore != null) {
            _selectedDate = (tanggalPenerimaanFirestore as Timestamp).toDate();
          }
          selectedNomorKonfirmasi = data['production_confirmation_id'];
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  void _initializeProductionConfirmation() {
    initProductionConf();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearForm() {
    setState(() {
      catatanController.clear();
      _selectedDate = null;
      selectedNomorKonfirmasi = null;
      statusController.text = 'Dalam Proses';
      materialDetailsData.clear();
      customCards.clear();
    });
  }

  void addOrUpdate() {
    final itemReceiveBloc = BlocProvider.of<ItemReceiveBloc>(context);
    final itemReceive = ItemReceive(
        id: '',
        productionConfirmationId: selectedNomorKonfirmasi ?? '',
        status: 1,
        statusIrc: statusController.text,
        tanggalPenerimaan: _selectedDate ?? DateTime.now(),
        detailItemReceiveList: [],
        catatan: catatanController.text);

    for (var productCardData in materialDetailsData) {
      final jumlah = productCardData['jumlah'].toDouble(); // Konversi ke double
      final detailItemReceive = DetailItemReceive(
        id: '',
        itemReceiveId: '',
        jumlahDus: (jumlah / 2000).toInt(), // Konversi hasil pembagian ke int
        jumlahKonfirmasi: jumlah.toInt(), // Konversi hasil pembagian ke int
        productId: productCardData['productId'],
        status: 1,
      );
      itemReceive.detailItemReceiveList.add(detailItemReceive);
    }

    if (widget.itemReceivceId != null) {
      itemReceiveBloc.add(
          UpdateItemReceiveEvent(widget.itemReceivceId ?? '', itemReceive));
    } else {
      itemReceiveBloc.add(AddItemReceiveEvent(itemReceive));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan penerimaan barang',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isProductionConf = selectedNomorKonfirmasi != null;
    return BlocListener<ItemReceiveBloc, ItemReceiveBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is ItemReceiveErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            ).then((_) {
              Navigator.pop(context, null);
            });
          } else if (state is ItemReceiveLoadingState) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is! ItemReceiveLoadingState) {
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
                            const SizedBox(width: 16.0),
                            const Flexible(
                              child: Text(
                                'Penerimaan Barang',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // Di dalam widget buildProductCard atau tempat lainnya
                        DatePickerButton(
                          label: 'Tanggal Penerimaan',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                          isEnabled: widget.statusIrc != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ProductionConfirmationDropDown(
                          selectedProductionConfirmationDropdown:
                              selectedNomorKonfirmasi,
                          onChanged: (newValue) {
                            setState(() {
                              selectedNomorKonfirmasi = newValue ?? '';
                              fetchConfirmations();
                            });
                          },
                          tanggalKonfirmasiController:
                              tanggalKonfirmasiController,
                          isEnabled: widget.itemReceivceId == null,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Tanggal Konfirmasi',
                          placeholder: 'Tanggal Konfirmasi',
                          controller: tanggalKonfirmasiController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusIrc != "Selesai",
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
                        if (!isProductionConf)
                          const Text(
                            'Detail Penerimaan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        if (!isProductionConf)
                          const Text(
                            'Tidak ada detail penerimaan',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        //cards
                        if (isProductionConf)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Penerimaan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: customCards.length,
                                itemBuilder: (context, index) {
                                  return customCards[index];
                                },
                              )
                            ],
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.statusIrc == "Selesai"
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
                                onPressed: widget.statusIrc == "Selesai"
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
