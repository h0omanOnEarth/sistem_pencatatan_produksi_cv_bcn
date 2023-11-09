import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transfer_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_transfer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_transfer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/bahanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_request_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPemindahanBahan extends StatefulWidget {
  static const routeName = '/gudang/produksi/pemindahan/form';
  final String? materialRequestId;
  final String? materialTransferId;
  final String? statusMtr;

  const FormPemindahanBahan(
      {Key? key,
      this.materialRequestId,
      this.materialTransferId,
      this.statusMtr})
      : super(key: key);

  @override
  State<FormPemindahanBahan> createState() => _FormPemindahanBahanState();
}

class _FormPemindahanBahanState extends State<FormPemindahanBahan> {
  DateTime? _selectedDate;
  String? selectedNomorPermintaan;
  bool isLoading = false;
  String? mode;

  TextEditingController catatanController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController tanggalPermintaanController = TextEditingController();
  TextEditingController productionOrderController = TextEditingController();
  List<Map<String, dynamic>> materialDetailsData = []; // Initialize the list
  List<Widget> customCards = [];

  final materialService = MaterialService();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

  void initializeMaterial() {
    selectedNomorPermintaan = widget.materialRequestId;
    firestore
        .collection('material_requests')
        .where('id',
            isEqualTo:
                widget.materialRequestId) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final materialData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final tanggalPermintaanFirestore = materialData['tanggal_permintaan'];
        if (tanggalPermintaanFirestore != null) {
          final timestamp = tanggalPermintaanFirestore as Timestamp;
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
          tanggalPermintaanController.text = formattedDate;
          productionOrderController.text = materialData['production_order_id'];
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
    mode = "add";
    statusController.text = "Dalam Proses";
    if (widget.materialTransferId != null) {
      firestore
          .collection('material_transfers')
          .doc(widget.materialTransferId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_mtr'];
            final tanggalPemindahanFirestore = data['tanggal_pemindahan'];
            if (tanggalPemindahanFirestore != null) {
              _selectedDate =
                  (tanggalPemindahanFirestore as Timestamp).toDate();
            }
            selectedNomorPermintaan = data['material_request_id'];
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.materialRequestId != null) {
      mode = "edit";
      fetchMaterialTransfer();
      initializeMaterial();
    }
  }

  Future<void> fetchMaterialTransfer() async {
    QuerySnapshot snapshot;

    if (widget.materialTransferId != null) {
      snapshot = await firestore
          .collection('material_transfers')
          .doc(widget.materialTransferId)
          .collection('detail_material_transfers')
          .get();
    } else {
      snapshot = await firestore
          .collection('material_requests')
          .doc(selectedNomorPermintaan)
          .collection('detail_material_requests')
          .get();
    }

    materialDetailsData.clear();
    customCards.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final materialId = data['material_id'] as String? ?? '';

      Future<Map<String, dynamic>> materialInfoFuture =
          materialService.fetchMaterialInfo(materialId);

      final materialInfoSnapshot = await materialInfoFuture;

      final materialName = materialInfoSnapshot['nama'] as String;
      final materialStock = materialInfoSnapshot['stok'] as int;

      Map<String, dynamic> detailMaterial = {
        'materialId': materialId,
        'jumlah': data['jumlah_bom'],
        'satuan': data['satuan'],
        if (widget.materialTransferId == null) 'batch': data['batch'],
        'stok': materialStock,
      };
      materialDetailsData.add(detailMaterial);

      final customCard = CustomCard(
        content: [
          CustomCardContent(text: 'Kode Bahan: $materialId'),
          CustomCardContent(text: 'Nama: $materialName'),
          CustomCardContent(text: 'Jumlah: ${data['jumlah_bom'].toString()}'),
          CustomCardContent(text: 'Stok: $materialStock'),
          CustomCardContent(text: 'Satuan: ${data['satuan'] ?? ''}'),
        ],
      );
      customCards.add(customCard);
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clear() {
    setState(() {
      _selectedDate = null;
      selectedNomorPermintaan = null;
      catatanController.clear();
      statusController.text = "Dalam Proses";
      materialDetailsData.clear();
      customCards.clear();
    });
  }

  void addOrUpdate() {
    mode = "edit";
    final materialTransferBloc = BlocProvider.of<MaterialTransferBloc>(context);
    final materialTransfer = MaterialTransfer(
        id: '',
        materialRequestId: selectedNomorPermintaan ?? '',
        statusMtr: statusController.text,
        tanggalPemindahan: _selectedDate ?? DateTime.now(),
        catatan: catatanController.text,
        status: 1,
        detailList: []);
    for (var productCardData in materialDetailsData) {
      final detailMaterialRequest = MaterialTransferDetail(
          id: '',
          jumlahBom: productCardData['jumlah'],
          materialId: productCardData['materialId'],
          materialTransferId: '',
          satuan: productCardData['satuan'],
          status: 1,
          stok: productCardData['stok']);
      materialTransfer.detailList.add(detailMaterialRequest);
    }

    if (widget.materialTransferId != null) {
      materialTransferBloc.add(UpdateMaterialTransferEvent(
          widget.materialTransferId ?? '', materialTransfer));
    } else {
      materialTransferBloc.add(AddMaterialTransferEvent(materialTransfer));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan pemindahan bahan.',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMaterialReqSelected = selectedNomorPermintaan != null;
    return BlocListener<MaterialTransferBloc, MaterialTransferBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false;
            });
          } else if (state is MaterialTransferErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            ).then((_) {
              Navigator.pop(context, null);
            });
          } else if (state is MaterialTransferLoadingState) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is! MaterialTransferLoadingState) {
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
                                'Pemindahan Bahan',
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
                          label: 'Tanggal Pemindahan',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                          isEnabled: widget.statusMtr != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        MaterialRequestDropdown(
                            selectedMaterialRequest: selectedNomorPermintaan,
                            onChanged: (newValue) {
                              setState(() {
                                selectedNomorPermintaan = newValue ?? '';
                                fetchMaterialTransfer();
                              });
                            },
                            nomorPerintahProduksiController:
                                productionOrderController,
                            tanggalPermintaanController:
                                tanggalPermintaanController,
                            isEnabled: widget.materialTransferId == null,
                            mode: mode),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Tanggal Permintaan',
                          placeholder: 'Tanggal Permintaan',
                          controller: tanggalPermintaanController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Nomor Perintah Produksi',
                          placeholder: 'Nomor Perintah Produksi',
                          controller: productionOrderController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusMtr != "Selesai",
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
                          height: 24.0,
                        ),
                        if (!isMaterialReqSelected)
                          const Text(
                            'Detail Pemindahan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        if (!isMaterialReqSelected)
                          const Text(
                            'Tidak ada detail pemindahan',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        //cards
                        if (isMaterialReqSelected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Pemindahan',
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
                                onPressed: widget.statusMtr == "Selesai"
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
                                onPressed: widget.statusMtr == "Selesai"
                                    ? null
                                    : () {
                                        // Handle clear button press
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
