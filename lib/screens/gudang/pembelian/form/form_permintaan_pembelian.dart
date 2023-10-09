import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/bahan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPermintaanPembelianScreen extends StatefulWidget {
  static const routeName = '/form_permintaan_pembelian_gudang_screen';
  final String? purchaseRequestId;
  final String? materialId;
  final String? statusPRQ;

  const FormPermintaanPembelianScreen({Key? key, this.purchaseRequestId, this.materialId, this.statusPRQ}) : super(key: key);
  
  @override
  State<FormPermintaanPembelianScreen> createState() =>
      _FormPermintaanPembelianScreenState();
}

class _FormPermintaanPembelianScreenState extends State<FormPermintaanPembelianScreen> {
  DateTime? _selectedDate;
  String? selectedKodeBahan;
  String selectedSatuan = "Kg";
  bool isLoading = false;


  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahProdukController = TextEditingController();
  TextEditingController namaBahanController =  TextEditingController();
  TextEditingController statusController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore

  @override
  void dispose() {
    selectedBahanNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKodeBahan = selectedBahanNotifier.value;
    });
  }

  void initializeMaterial(){
    selectedKodeBahan = widget.materialId;
    firestore
    .collection('materials')
    .where('id', isEqualTo: selectedKodeBahan) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      final bahanData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final namaProduk = bahanData['nama'];
      namaBahanController.text = namaProduk ?? '';
    } else {
      print('Document does not exist on Firestore');
    }
  }).catchError((error) {
    print('Error getting document: $error');
  });
  }

  @override
  void initState(){
    super.initState();
     // untuk mengganti selected kode dari file dropdown 
    statusController.text = "Dalam Proses";

    if(widget.purchaseRequestId!=null){
       firestore
        .collection('purchase_requests')
        .doc(widget.purchaseRequestId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_prq'];
          jumlahProdukController.text = data['jumlah'].toString();
          final tanggalPermintaanFirestore = data['tanggal_permintaan'];
          if (tanggalPermintaanFirestore != null) {
            _selectedDate = (tanggalPermintaanFirestore as Timestamp).toDate();
          }
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
    }

    if(widget.materialId!=null){
      initializeMaterial();
    }

  WidgetsBinding.instance.addPostFrameCallback((_) {
     selectedBahanNotifier.addListener(_selectedKodeListener);
     selectedKodeBahan = selectedBahanNotifier.value;
  });
}

  void clearForm() {
  setState(() {
    _selectedDate = null;
    selectedKodeBahan = null;
    namaBahanController.clear();
    jumlahProdukController.clear();
    selectedSatuan = "Kg";
    catatanController.clear();
    statusController.text = "Dalam Proses";
  });
}

void addOrUpdate(){
  final purchaseRequestBloc = BlocProvider.of<PurchaseRequestBloc>(context);
  final purchaseRequeset = PurchaseRequest(id: '', catatan: catatanController.text, jumlah: int.tryParse(jumlahProdukController.text)??0, materialId: selectedKodeBahan??'', satuan: selectedSatuan, status: 1, statusPrq: statusController.text, tanggalPermintaan: _selectedDate??DateTime.now());

  if(widget.purchaseRequestId!=null){
    purchaseRequestBloc.add(UpdatePurchaseRequestEvent(widget.purchaseRequestId??'', purchaseRequeset));
  }else{
    purchaseRequestBloc.add(AddPurchaseRequestEvent(purchaseRequeset));
  }
}


  void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan pesanan permintaan pembelian bahan.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }

  @override
  Widget build(BuildContext context) {
  return BlocListener<PurchaseRequestBloc, PurchaseRequestBlocState>(
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
            Align(
            alignment: Alignment.topCenter,
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
                          'Permintaan Pembelian',
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
                        label: 'Tanggal Permintaan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: BahanDropdown(namaBahanController: namaBahanController, bahanId: widget.materialId,)
                      ),
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
                  const SizedBox(height: 16.0,),
                    Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          label: 'Jumlah Produk',
                          placeholder: 'Jumlah Produk',
                          controller: jumlahProdukController,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: 
                        DropdownWidget(
                          label: 'Satuan',
                          selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                          items: const ['Pcs', 'Kg', 'Ons'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                              print('Selected value: $newValue');
                            });
                          },
                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                    label: 'Catatan',
                    placeholder: 'Catatan',
                    controller: catatanController,
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                    label: 'Status',
                    placeholder: 'Dalam Proses',
                    isEnabled: false,
                    controller: statusController,
                  ),
                  const SizedBox(height: 24.0,),
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
          if (isLoading)
              Positioned( // Menambahkan Positioned untuk indikator loading
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Latar belakang semi-transparan
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        )
      ),
    )
    );
  }
}
