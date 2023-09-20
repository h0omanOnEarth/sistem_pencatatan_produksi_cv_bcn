import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_result_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_result.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_usage_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormHasilProduksiScreen extends StatefulWidget {
  static const routeName = '/form_pencatatan_hasil_produksi_screen';
  final String? materialUsageId;
  final String? productionResultId;

  const FormHasilProduksiScreen({Key? key, this.materialUsageId, this.productionResultId}) : super(key: key);
  
  @override
  State<FormHasilProduksiScreen> createState() =>
      _FormHasilProduksiScreenState();
}

class _FormHasilProduksiScreenState extends State<FormHasilProduksiScreen> {
  DateTime? _selectedDate;
  String? selectedPenggunaanBahan;
  String selectedSatuan = "Kg";

  TextEditingController nomorPerintahProduksiController = TextEditingController();
  TextEditingController namaBatchController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahProdukCacatController = TextEditingController();
  TextEditingController jumlahProdukBerhasilController =TextEditingController();
  TextEditingController waktuProduksiController = TextEditingController();
  TextEditingController jumlahProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore

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
  final jumlahProdukBerhasil = int.tryParse(jumlahProdukBerhasilController.text) ?? 0;
  final jumlahProdukCacat = int.tryParse(jumlahProdukCacatController.text) ?? 0;
  final totalProduk = jumlahProdukBerhasil + jumlahProdukCacat;
  jumlahProdukController.text = totalProduk.toString();
}

 @override
  void initState() {
    super.initState();
    statusController.text = "Dalam Proses"; 
 }

  @override
  void dispose() {
    super.dispose();
  }

  void addOrUpdate(){
     final proResBloc =BlocProvider.of<ProductionResultBloc>(context);
     final productionResult = ProductionResult(id: '', materialUsageId: selectedPenggunaanBahan??'', totalProduk: int.parse(jumlahProdukController.text), jumlahProdukBerhasil: int.parse(jumlahProdukBerhasilController.text), jumlahProdukCacat: int.parse(jumlahProdukCacatController.text), satuan: selectedSatuan, catatan: catatanController.text, statusPRS: statusController.text, status: 1, tanggalPencatatan: _selectedDate?? DateTime.now(), waktuProduksi: int.parse(waktuProduksiController.text));
     if(widget.productionResultId!=null){
      proResBloc.add(UpdateProductionResultEvent(widget.productionResultId??'', productionResult));
     }else{
      proResBloc.add(AddProductionResultEvent(productionResult));
     }

     _showSuccessMessageAndNavigateBack();
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
    Navigator.pop(context,null);
  });
}

  @override
  Widget build(BuildContext context) {
    jumlahProdukBerhasilController.addListener(updateTotalProduk);
    jumlahProdukCacatController.addListener(updateTotalProduk);
    return BlocProvider(
    create: (context) => ProductionResultBloc(),
    child: Scaffold(
      body: SafeArea(
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
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
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
                  ),
                const SizedBox(height: 16.0),
                MaterialUsageDropdown(selectedMaterialUsage: selectedPenggunaanBahan, onChanged: (newValue) {
                      setState(() {
                        selectedPenggunaanBahan = newValue??'';
                      });
                }, nomorPerintahProduksiController: nomorPerintahProduksiController, namaBatchController: namaBatchController,),
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
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Produk Cacat',
                  placeholder: 'Jumlah Produk Cacat',
                  controller: jumlahProdukCacatController,
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Produk Berhasil',
                  placeholder: 'Jumlah Produk Berhasil',
                  controller: jumlahProdukBerhasilController,
                ),
                const SizedBox(height: 16.0,),
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
                      child: 
                      DropdownWidget(
                        label: 'Satuan',
                        selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                        items: const ['Pcs', 'Kg', 'Ons'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          });
                        },
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(child: 
                      TextFieldWidget(
                      label: 'Waktu Produksi',
                      placeholder: 'Waktu Produksi',
                      controller: waktuProduksiController,
                      ),
                    ), 
                    const SizedBox(width: 16.0,),
                    const Expanded(child: 
                    TextFieldWidget(
                      label: '',
                      placeholder: 'Menit',
                      isEnabled: false,
                      ),
                    )
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
                const SizedBox(height: 16.0,),
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
                          clear();
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
    )
    );
  }
}
