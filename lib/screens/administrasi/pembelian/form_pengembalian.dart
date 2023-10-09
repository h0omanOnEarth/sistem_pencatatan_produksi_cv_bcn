import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/pesanan_pembelian_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPengembalianPesananScreen extends StatefulWidget {
  static const routeName = '/form_pengembalian_pesanan_pembelian_screen';

  final String? purchaseReturnId; 
  final String? purchaseOrderId;
  final int? qtyLama;
  const FormPengembalianPesananScreen({Key? key, this.purchaseReturnId, this.purchaseOrderId, this.qtyLama}) : super(key: key);
  
  @override
  State<FormPengembalianPesananScreen> createState() =>
      _FormPengembalianPesananScreenState();
}

class _FormPengembalianPesananScreenState extends State<FormPengembalianPesananScreen> {
  DateTime? _selectedDate;
  String? selectedPesanan;
  String _selectedSatuan = "Kg";
  String? dropdownValue;
  bool isLoading = false;


  TextEditingController tanggalPemesananController = TextEditingController();
  TextEditingController kodeBahanController = TextEditingController();
  TextEditingController namaBahanController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController alamatPengembalianController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController alasanController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

 // init state
@override
void initState() {
  super.initState();
  // Ambil data Purchase Return jika purchaseReturnId tidak null
  if (widget.purchaseReturnId != null) {
    FirebaseFirestore.instance
      .collection('purchase_returns')
      .where('id', isEqualTo: widget.purchaseReturnId)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            alamatPengembalianController.text = data['alamat_pengembalian'];
            jumlahController.text = data['jumlah'].toString();
            alasanController.text = data['alasan'].toString();
            catatanController.text = data['keterangan'].toString();
            final tanggalPengembalianFirestore = data['tanggal_pengembalian'];
            if (tanggalPengembalianFirestore != null) {
              _selectedDate = tanggalPengembalianFirestore.toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
  }

  // Periksa jika widget.purchaseOrderId tidak null
  if (widget.purchaseOrderId != null) {
    selectedPesanan = widget.purchaseOrderId;
    FirebaseFirestore.instance
      .collection('purchase_orders')
      .where('id', isEqualTo: widget.purchaseOrderId)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final purchaseOrderData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          Timestamp timestamp = purchaseOrderData['tanggal_pesan'] as Timestamp;
          DateTime date = timestamp.toDate();
          String formattedDate = DateFormat('dd/MM/yyyy').format(date);
          tanggalPemesananController.text = formattedDate;
          kodeBahanController.text = purchaseOrderData['material_id'];
          String materialId = purchaseOrderData['material_id'];
          // Ambil data nama bahan dan supplier dari koleksi 'materials' dan 'suppliers'
          FirebaseFirestore.instance
            .collection('materials')
            .where('id', isEqualTo: materialId)
            .get()
            .then((QuerySnapshot materialSnapshot) {
              if (materialSnapshot.docs.isNotEmpty) {
                var materialDoc = materialSnapshot.docs[0];
                String namaBahan = materialDoc['nama'] ?? '';
                namaBahanController.text = namaBahan;
              }
            });
            
          String supplierId = purchaseOrderData['supplier_id'];
          FirebaseFirestore.instance
            .collection('suppliers')
            .where('id', isEqualTo: supplierId)
            .get()
            .then((QuerySnapshot supplierSnapshot) {
              if (supplierSnapshot.docs.isNotEmpty) {
                var supplierDoc = supplierSnapshot.docs[0];
                String namaSupplier = supplierDoc['nama'] ?? '';
                supplierController.text = namaSupplier;
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
    selectedKodeNotifier.addListener(_selectedKodeListener);
    selectedPesanan = selectedKodeNotifier.value;
});
}

  @override
  void dispose() {
    // Hapus listener pada saat widget di dispose
    selectedKodeNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedPesanan = selectedKodeNotifier.value;
    });
  }


  void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan pesan pengembalian.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }

   void addOrUpdatePurchaseReturn() {
    final purchaseReturnBloc = BlocProvider.of<PurchaseReturnBloc>(context);
    final PurchaseReturn newPurchaseReturn =  PurchaseReturn(id: '', purchaseOrderId: selectedPesanan??'', jumlah: int.tryParse(jumlahController.text)??0, satuan: _selectedSatuan, alamatPengembalian: alamatPengembalianController.text, alasan: alasanController.text, status: 1, tanggalPengembalian: _selectedDate ?? DateTime.now(), jenis_bahan: '', keterangan: catatanController.text);

    if(widget.purchaseReturnId!=null){
      purchaseReturnBloc.add(UpdatePurchaseReturnEvent(widget.purchaseReturnId ?? '',newPurchaseReturn, widget.qtyLama??0));
    }else{
      purchaseReturnBloc.add(AddPurchaseReturnEvent(newPurchaseReturn));
    }
  }
  
  @override
  Widget build(BuildContext context) {
      return BlocListener<PurchaseReturnBloc, PurchaseReturnBlocState>(
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
                              Navigator.pop(context);
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
                              child:const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.arrow_back, color: Colors.black),
                              ),
                            ),
                          ),
                        const SizedBox(width: 16.0),
                          const Text(
                            'Pengembalian Pesanan Pembelian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      PesananPembelianDropdown(kodeBahanController: kodeBahanController, namaBahanController: namaBahanController, namaSupplierController: supplierController, tanggalPemesananController: tanggalPemesananController,purchaseOrderId: widget.purchaseOrderId,),
                      const SizedBox(height: 16.0,),
                      TextFieldWidget(
                        label: 'Tanggal Pemesanan',
                        placeholder: 'Tanggal Pemesanan',
                        controller: tanggalPemesananController,
                        isEnabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Kode Bahan',
                              placeholder: 'Kode Bahan',
                              controller: kodeBahanController,
                              isEnabled: false,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Nama Bahan',
                              placeholder: 'Nama Bahan',
                              controller: namaBahanController,
                              isEnabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        label: 'Nama Supplier',
                        placeholder: 'Nama Supplier',
                        controller: supplierController,
                        isEnabled: false,
                      ),
                      const SizedBox(height: 16.0,),
                      TextFieldWidget(
                          label: 'Alamat Pengembalian',
                          placeholder: 'Alamat Pengembalian',
                          controller: alamatPengembalianController,
                          multiline: true,
                        ),
                      const SizedBox(height: 16.0,),
                      DatePickerButton(
                              label: 'Tanggal Pengembalian',
                              selectedDate: _selectedDate,
                              onDateSelected: (newDate) {
                                setState(() {
                                  _selectedDate = newDate;
                                });
                              },
                      ), 
                      const SizedBox(height: 16.0,),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Jumlah',
                              placeholder: 'Jumlah',
                              controller: jumlahController,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child:  DropdownWidget(
                            label: 'Satuan',
                            selectedValue: _selectedSatuan, // Isi dengan nilai yang sesuai
                            items: const ['Kg','Ons','Pcs','Gram','Sak'],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                              });
                            },
                          ),
                            
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0,),
                        TextFieldWidget(
                        label: 'Alasan',
                        placeholder: 'Alasan',
                        controller: alasanController,
                        multiline: true,
                      ),
                      const SizedBox(height: 16.0,),
                        TextFieldWidget(
                        label: 'Cataan',
                        placeholder: 'Catatan',
                        controller: catatanController,
                      ),
                      const SizedBox(height: 16.0,),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle save button press
                                addOrUpdatePurchaseReturn();
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
                                  _selectedDate =  null;
                                  selectedPesanan = null;
                                  _selectedSatuan = "Kg";
                                  tanggalPemesananController.clear();
                                  kodeBahanController.clear(); 
                                  namaBahanController.clear();  
                                  supplierController.clear();  
                                  alamatPengembalianController.clear(); 
                                  jumlahController.clear(); 
                                  alasanController.clear(); 
                                  catatanController.clear();
                                  setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Padding(
                                padding:  EdgeInsets.symmetric(vertical: 16.0),
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
