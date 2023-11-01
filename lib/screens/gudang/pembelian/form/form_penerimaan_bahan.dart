import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/penerimaan_bahan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/material_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/bahanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/supplierService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/bahan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/purchaseRequestDropDown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/supplier_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenerimaanBahanScreen extends StatefulWidget {
  static const routeName = '/gudang/pembelian/penerimaan/form';
  final String? purchaseRequestId;
  final String? materialReceiveId;
  final String? materialId;
  final int? stokLama;

  const FormPenerimaanBahanScreen(
      {Key? key,
      this.purchaseRequestId,
      this.materialReceiveId,
      this.materialId,
      this.stokLama})
      : super(key: key);

  @override
  State<FormPenerimaanBahanScreen> createState() =>
      _FormPenerimaanBahanScreenState();
}

class _FormPenerimaanBahanScreenState extends State<FormPenerimaanBahanScreen> {
  DateTime? _selectedDate;
  String? selectedNomorPermintaan;
  String? selectedKodeBahan;
  String? selectedSupplier;
  String? dropdownValue;
  bool isLoading = false;

  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahDiterimaController = TextEditingController();
  TextEditingController kodeSupplierController = TextEditingController();
  TextEditingController namaBahanController = TextEditingController();
  TextEditingController jumlahPermintaanController = TextEditingController();
  TextEditingController satuanController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final supplierService = SupplierService();
  final materialService = MaterialService();

  @override
  void initState() {
    super.initState();

    if (widget.materialReceiveId != null) {
      firestore
          .collection('material_receives')
          .doc(widget.materialReceiveId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;

          final String? supplierId = data['supplier_id'];
          final String? materialId = data['material_id'];

          // Cek apakah data supplier dan material sudah dimuat sebelum memanggil setState
          if (supplierId != null && materialId != null) {
            _loadSupplierAndMaterialData(supplierId, materialId);
          }

          setState(() {
            catatanController.text = data['catatan'] ?? '';
            jumlahDiterimaController.text = data['jumlah_diterima'].toString();
            jumlahPermintaanController.text =
                data['jumlah_permintaan'].toString();
            selectedKodeBahan = data['material_id'] ?? '';
            selectedNomorPermintaan = data['purchase_request_id'] ?? '';
            satuanController.text = data['satuan'] ?? '';
            selectedSupplier = data['supplier_id'] ?? '';

            final tanggalPenerimaanFirestore = data['tanggal_penerimaan'];
            if (tanggalPenerimaanFirestore != null) {
              _selectedDate =
                  (tanggalPenerimaanFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedBahanNotifier.addListener(_selectedKodeListener);
      selectedKodeBahan = selectedBahanNotifier.value;
    });
  }

// Buat fungsi async untuk mengambil data supplier dan material
  Future<void> _loadSupplierAndMaterialData(
      String? supplierId, String? materialId) async {
    if (supplierId != null) {
      Map<String, dynamic>? supplier =
          await supplierService.getSupplierInfo(supplierId);
      kodeSupplierController.text = supplier?['id'] as String;
    }

    if (materialId != null) {
      Map<String, dynamic>? material =
          await materialService.getMaterialInfo(materialId);
      namaBahanController.text = material?['nama'] as String;
    }
  }

  @override
  void dispose() {
    selectedBahanNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  void clearForm() {
    setState(() {
      _selectedDate = null;
      selectedNomorPermintaan = null;
      selectedKodeBahan = null;
      selectedSupplier = null;
      dropdownValue = null;
      catatanController.clear();
      jumlahDiterimaController.clear();
      kodeSupplierController.clear();
      namaBahanController.clear();
      jumlahPermintaanController.clear();
      satuanController.clear();
    });
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKodeBahan = selectedBahanNotifier.value;
    });
  }

  void addOrUpdate() {
    final materialReceiveBloc = BlocProvider.of<MaterialReceiveBloc>(context);
    final materialReceive = MaterialReceive(
        id: '',
        purchaseRequestId: selectedNomorPermintaan ?? '',
        materialId: selectedKodeBahan ?? '',
        supplierId: selectedSupplier ?? '',
        satuan: satuanController.text,
        jumlahPermintaan: int.tryParse(jumlahPermintaanController.text) ?? 0,
        jumlahDiterima: int.tryParse(jumlahDiterimaController.text) ?? 0,
        status: 1,
        catatan: catatanController.text,
        tanggalPenerimaan: _selectedDate ?? DateTime.now());

    if (widget.materialReceiveId != null) {
      materialReceiveBloc.add(UpdateMaterialReceiveEvent(
          widget.materialReceiveId ?? '',
          materialReceive,
          widget.stokLama ?? 0));
    } else {
      materialReceiveBloc.add(AddMaterialReceiveEvent(materialReceive));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan pesanan permintaan penerimaan bahan',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialReceiveBloc, MaterialReceiveBlocState>(
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
                                'Penerimaan Bahan',
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
                          label: 'Tanggal Penerimaan',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        PurchaseRequestDropDown(
                          selectedPurchaseRequest: selectedNomorPermintaan,
                          onChanged: (newValue) {
                            setState(() {
                              selectedNomorPermintaan = newValue ?? '';
                            });
                          },
                          jumlahPermintaanController:
                              jumlahPermintaanController,
                          isEnabled: widget.materialReceiveId == null,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SupplierDropdown(
                                selectedSupplier: selectedSupplier,
                                kodeSupplierController: kodeSupplierController,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedSupplier = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Kode Supplier',
                                placeholder: 'Kode Supplier',
                                isEnabled: false,
                                controller: kodeSupplierController,
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
                                child: BahanDropdown(
                              namaBahanController: namaBahanController,
                              bahanId: widget.materialId,
                              satuanBahanController: satuanController,
                            )),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Nama Bahan',
                                placeholder: 'Nama Bahan',
                                isEnabled: false,
                                controller: namaBahanController,
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
                                label: 'Jumlah Permintaan',
                                placeholder: 'Jumlah Permintaan',
                                isEnabled: false,
                                controller: jumlahPermintaanController,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Satuan',
                                placeholder: 'Kg',
                                isEnabled: false,
                                controller: satuanController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Jumlah Diterima',
                          placeholder: 'Jumlah Diterima',
                          controller: jumlahDiterimaController,
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
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
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
                                onPressed: () {
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
