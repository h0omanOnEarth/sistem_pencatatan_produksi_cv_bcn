import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionorder_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPermintaanBahanScreen extends StatefulWidget {
  static const routeName = '/produksi/proses/permintaan/form';
  final String? productionOrderId;
  final String? materialRequestId;
  final String? statusMr;

  const FormPermintaanBahanScreen(
      {Key? key, this.productionOrderId, this.materialRequestId, this.statusMr})
      : super(key: key);

  @override
  State<FormPermintaanBahanScreen> createState() =>
      _FormPermintaanBahanScreenState();
}

class _FormPermintaanBahanScreenState extends State<FormPermintaanBahanScreen> {
  DateTime? _selectedTanggalPermintaan;
  String? selectedNoPerintah;
  bool isLoading = false;
  bool isSave = false;
  List<CustomCard> customCards = [];

  TextEditingController tanggalProduksiController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController kodeBOMController = TextEditingController();
  TextEditingController kodeProdukController = TextEditingController();
  TextEditingController namaProdukController = TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore
  List<Map<String, dynamic>> materialDetailsData = []; // Initialize the list
  final productService = ProductService();

  Future<void> fetchProductionOrders() async {
    QuerySnapshot snapshot;

    if (widget.materialRequestId != null) {
      snapshot = await firestore
          .collection('material_requests')
          .doc(widget.materialRequestId)
          .collection('detail_material_requests')
          .get();
    } else {
      snapshot = await firestore
          .collection('production_orders')
          .doc(selectedNoPerintah)
          .collection('detail_production_orders')
          .get();
    }

    materialDetailsData.clear();
    customCards.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final materialId = data['material_id'] as String? ?? '';

      if (materialId != "material011" && materialId != "material012") {
        Future<Map<String, dynamic>> materialInfoFuture =
            fetchMaterialInfo(materialId);

        final materialInfoSnapshot = await materialInfoFuture;

        final materialName = materialInfoSnapshot['nama'] as String;
        final materialStock = materialInfoSnapshot['stok'] as int;
        final jumlahBOM =
            data['jumlah_bom'] as int? ?? 0; // Ubah ini sesuai kebutuhan

        customCards.add(
          CustomCard(
            content: [
              CustomCardContent(text: 'Kode Bahan: $materialId'),
              CustomCardContent(text: 'Nama: $materialName'),
              CustomCardContent(text: 'Batch: ${data['batch']}'),
              CustomCardContent(text: 'Jumlah: $jumlahBOM'),
              CustomCardContent(text: 'Stok: $materialStock'),
              CustomCardContent(text: 'Satuan: ${data['satuan'] ?? ''}'),
            ],
          ),
        );

        Map<String, dynamic> detailMaterial = {
          'materialId': materialId,
          'jumlah': jumlahBOM,
          'satuan': data['satuan'],
          'batch': data['batch'],
        };
        materialDetailsData.add(detailMaterial);
      }
    }
    setState(() {});
  }

  Future<Map<String, dynamic>> fetchMaterialInfo(String materialId) async {
    final materialQuery = await firestore
        .collection('materials')
        .where('id', isEqualTo: materialId)
        .get();

    if (materialQuery.docs.isNotEmpty) {
      final materialData = materialQuery.docs.first.data();
      final materialName = materialData['nama'] as String? ?? '';
      final materialStock = materialData['stok'] as int? ?? 0;

      return {
        'nama': materialName,
        'stok': materialStock,
      };
    }

    return {
      'nama': '',
      'stok': 0,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeMaterial() async {
    selectedNoPerintah = widget.productionOrderId;
    firestore
        .collection('production_orders')
        .where('id',
            isEqualTo:
                widget.productionOrderId) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        final materialData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final tanggalProduksiFirestore = materialData['tanggal_produksi'];
        if (tanggalProduksiFirestore != null) {
          final timestamp = tanggalProduksiFirestore as Timestamp;
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

          final formattedDate = '$month $day, $year';
          tanggalProduksiController.text = formattedDate;
          kodeProdukController.text = materialData['product_id'];
          kodeBOMController.text = materialData['bom_id'];
          final productInfo =
              await productService.getProductInfo(materialData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';
          namaProdukController.text = productName;
        }
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
    statusController.text = "Dalam Proses";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.materialRequestId != null) {
      firestore
          .collection('material_requests')
          .doc(widget.materialRequestId)
          .get()
          .then(
        (DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            final data = documentSnapshot.data() as Map<String, dynamic>;
            setState(() {
              catatanController.text = data['catatan'] ?? '';
              statusController.text = data['status_mr'];
              final tanggalPermintaanFirestore = data['tanggal_permintaan'];
              if (tanggalPermintaanFirestore != null) {
                _selectedTanggalPermintaan =
                    (tanggalPermintaanFirestore as Timestamp).toDate();
              }
              selectedNoPerintah = data['production_order_id'];
            });
          } else {
            print('Document does not exist on Firestore');
          }
        },
      ).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.productionOrderId != null) {
      fetchProductionOrders();
      initializeMaterial();
    }
  }

  void clearFields() {
    setState(() {
      _selectedTanggalPermintaan = null;
      selectedNoPerintah = null;
      tanggalProduksiController.clear();
      catatanController.clear();
      statusController.text = "Dalam Proses";
      materialDetailsData.clear();
      customCards.clear();
    });
  }

  void addOrUpdate() {
    final materialRequestBloc = BlocProvider.of<MaterialRequestBloc>(context);
    try {
      final materialRequest = MaterialRequest(
          id: '',
          productionOrderId: selectedNoPerintah ?? '',
          status: 1,
          statusMr: statusController.text,
          tanggalPermintaan: _selectedTanggalPermintaan ?? DateTime.now(),
          detailMaterialRequestList: [],
          catatan: catatanController.text);

      for (var productCardData in materialDetailsData) {
        final detailMaterialRequest = DetailMaterialRequest(
            id: '',
            jumlahBom: productCardData['jumlah'],
            materialId: productCardData['materialId'],
            materialRequestId: '',
            satuan: productCardData['satuan'],
            batch: productCardData['batch'],
            status: 1);
        materialRequest.detailMaterialRequestList.add(detailMaterialRequest);
      }

      if (widget.materialRequestId != null) {
        materialRequestBloc.add(UpdateMaterialRequestEvent(
            widget.materialRequestId ?? '', materialRequest));
      } else {
        materialRequestBloc.add(AddMaterialRequestEvent(materialRequest));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan permintaan bahan.',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPROselected = selectedNoPerintah != null;
    return BlocListener<MaterialRequestBloc, MaterialRequestBlocState>(
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
                            const SizedBox(width: 16.0),
                            const Flexible(
                              child: Text(
                                'Permintaan Bahan',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        DatePickerButton(
                          label: 'Tanggal Permintaan',
                          selectedDate: _selectedTanggalPermintaan,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedTanggalPermintaan = newDate;
                            });
                          },
                          isEnabled: widget.statusMr != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ProductionOrderDropDown(
                          selectedPRO: selectedNoPerintah,
                          onChanged: (newValue) {
                            setState(() {
                              selectedNoPerintah = newValue ?? '';
                              fetchProductionOrders();
                            });
                          },
                          tanggalProduksiController: tanggalProduksiController,
                          isEnabled: widget.materialRequestId == null,
                          kodeProdukController: kodeProdukController,
                          kodeBomController: kodeBOMController,
                          namaProdukController: namaProdukController,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Kode Produk',
                          placeholder: 'Kode Produk',
                          controller: kodeProdukController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Nama Produk',
                          placeholder: 'Nama Produk',
                          controller: namaProdukController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Kode BOM',
                          placeholder: 'Kode BOM',
                          controller: kodeBOMController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Tanggal Produksi',
                          placeholder: 'Tanggal Produksi',
                          controller: tanggalProduksiController,
                          isEnabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                            label: 'Status',
                            placeholder: 'Dalam Proses',
                            isEnabled: false,
                            controller: statusController),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusMr != "Selesai",
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        if (!isPROselected)
                          const Text(
                            'Detail Bahan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        if (!isPROselected)
                          const Text(
                            'Tidak ada detail bahan',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        if (isPROselected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Bahan',
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
                                onPressed: widget.statusMr == "Selesai"
                                    ? null
                                    : () {
                                        addOrUpdate();
                                        isSave = true;
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
                                onPressed: widget.statusMr == "Selesai"
                                    ? null
                                    : () {
                                        // Handle clear button press
                                        clearFields();
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
