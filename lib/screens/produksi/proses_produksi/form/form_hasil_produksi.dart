import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_result_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_result.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_usage_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormHasilProduksiScreen extends StatefulWidget {
  static const routeName = '/produksi/proses/hasil/form';
  final String? materialUsageId;
  final String? productionResultId;
  final String? statusPrs;

  const FormHasilProduksiScreen(
      {Key? key, this.materialUsageId, this.productionResultId, this.statusPrs})
      : super(key: key);

  @override
  State<FormHasilProduksiScreen> createState() =>
      _FormHasilProduksiScreenState();
}

class _FormHasilProduksiScreenState extends State<FormHasilProduksiScreen> {
  DateTime? _selectedDate;
  String? selectedPenggunaanBahan;
  String selectedSatuan = "Kg";
  bool isLoading = false;

  TextEditingController nomorPerintahProduksiController =
      TextEditingController();
  TextEditingController namaBatchController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahProdukCacatController = TextEditingController();
  TextEditingController jumlahProdukBerhasilController =
      TextEditingController();
  TextEditingController waktuProduksiController = TextEditingController();
  TextEditingController jumlahProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

  void clear() {
    setState(() {
      _selectedDate = null;
      selectedPenggunaanBahan = '';
      selectedSatuan = 'Kg';
      nomorPerintahProduksiController.clear();
      namaBatchController.clear();
      catatanController.clear();
      jumlahProdukCacatController.clear();
      jumlahProdukBerhasilController.clear();
      waktuProduksiController.clear();
      jumlahProdukController.clear();
      statusController.text = "Dalam Proses";
    });
  }

  void updateTotalProduk() {
    final jumlahProdukBerhasil =
        int.tryParse(jumlahProdukBerhasilController.text) ?? 0;
    final jumlahProdukCacat =
        int.tryParse(jumlahProdukCacatController.text) ?? 0;
    final totalProduk = jumlahProdukBerhasil + jumlahProdukCacat;
    jumlahProdukController.text = totalProduk.toString();
  }

  void initializeMaterialUsage() {
    selectedPenggunaanBahan = widget.materialUsageId;
    firestore
        .collection('material_usages')
        .where('id',
            isEqualTo:
                selectedPenggunaanBahan) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        final productData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        namaBatchController.text = productData['batch'];
        nomorPerintahProduksiController.text =
            productData['production_order_id'];
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

    if (widget.productionResultId != null) {
      firestore
          .collection('production_results')
          .doc(widget.productionResultId) // Menggunakan widget.customerOrderId
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_prs'];
            selectedPenggunaanBahan = data['material_usage_id'];
            jumlahProdukBerhasilController.text =
                data['jumlah_produk_berhasil'].toString();
            jumlahProdukCacatController.text =
                data['jumlah_produk_cacat'].toString();
            jumlahProdukController.text = data['total_produk'].toString();
            waktuProduksiController.text = data['waktu_produksi'].toString();
            selectedSatuan = data['satuan'];
            final tanggalPencatatanFirestore = data['tanggal_pencatatan'];
            if (tanggalPencatatanFirestore != null) {
              _selectedDate =
                  (tanggalPencatatanFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.materialUsageId != null) {
      initializeMaterialUsage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addOrUpdate() {
    final proResBloc = BlocProvider.of<ProductionResultBloc>(context);
    final productionResult = ProductionResult(
        id: '',
        materialUsageId: selectedPenggunaanBahan ?? '',
        totalProduk: int.tryParse(jumlahProdukController.text) ?? 0,
        jumlahProdukBerhasil:
            int.tryParse(jumlahProdukBerhasilController.text) ?? 0,
        jumlahProdukCacat: int.tryParse(jumlahProdukCacatController.text) ?? 0,
        satuan: selectedSatuan,
        catatan: catatanController.text,
        statusPRS: statusController.text,
        status: 1,
        tanggalPencatatan: _selectedDate ?? DateTime.now(),
        waktuProduksi: int.tryParse(waktuProduksiController.text) ?? 0);
    if (widget.productionResultId != null) {
      proResBloc.add(UpdateProductionResultEvent(
          widget.productionResultId ?? '', productionResult));
    } else {
      proResBloc.add(AddProductionResultEvent(productionResult));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan hasil produksi',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    jumlahProdukBerhasilController.addListener(updateTotalProduk);
    jumlahProdukCacatController.addListener(updateTotalProduk);
    return BlocListener<ProductionResultBloc, ProductionResultBlocState>(
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
            ).then((_) {
              Navigator.pop(context, null);
            });
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
                                'Hasil Produksi',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        DatePickerButton(
                          label: 'Tanggal Pencatatan',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                          isEnabled: widget.statusPrs != "Selesai",
                        ),
                        const SizedBox(height: 16.0),
                        MaterialUsageDropdown(
                          selectedMaterialUsage: selectedPenggunaanBahan,
                          onChanged: (newValue) {
                            setState(() {
                              selectedPenggunaanBahan = newValue ?? '';
                            });
                          },
                          nomorPerintahProduksiController:
                              nomorPerintahProduksiController,
                          namaBatchController: namaBatchController,
                          isEnabled: widget.productionResultId == null,
                          feature: "result",
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Nomor Perintah Produksi',
                                placeholder: 'Nomor Perintah Produksi',
                                controller: nomorPerintahProduksiController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Batch',
                                placeholder: 'Batch',
                                controller: namaBatchController,
                                isEnabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Jumlah Produk Cacat',
                          placeholder: 'Jumlah Produk Cacat',
                          controller: jumlahProdukCacatController,
                          isEnabled: widget.statusPrs != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Jumlah Produk Berhasil',
                          placeholder: 'Jumlah Produk Berhasil',
                          controller: jumlahProdukBerhasilController,
                          isEnabled: widget.statusPrs != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Jumlah Produk',
                                placeholder: 'Jumlah Produk',
                                controller: jumlahProdukController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: DropdownWidget(
                                label: 'Satuan',
                                selectedValue:
                                    selectedSatuan, // Isi dengan nilai yang sesuai
                                items: const ['Pcs', 'Kg', 'Ons'],
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedSatuan =
                                        newValue; // Update _selectedValue saat nilai berubah
                                  });
                                },
                                isEnabled: widget.statusPrs != "Selesai",
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
                                label: 'Waktu Produksi',
                                placeholder: 'Waktu Produksi',
                                controller: waktuProduksiController,
                                isEnabled: widget.statusPrs != "Selesai",
                              ),
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            const Expanded(
                              child: TextFieldWidget(
                                label: '',
                                placeholder: 'Menit',
                                isEnabled: false,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusPrs != "Selesai",
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
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.statusPrs == "Selesai"
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
                                onPressed: widget.statusPrs == "Selesai"
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
