import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/penerimaan_bahan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/bahan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/purchaseRequestDropDown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/supplier_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenerimaanBahanScreen extends StatefulWidget {
  static const routeName = '/form_penerimaan_bahan_screen';
  final String? purchaseRequestId;
  final String? materialReceiveId;
  final String? materialId;

  const FormPenerimaanBahanScreen({Key? key, this.purchaseRequestId, this.materialReceiveId, this.materialId}) : super(key: key);
  
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

  
  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahDiterimaController = TextEditingController();
  TextEditingController kodeSupplierController = TextEditingController();
  TextEditingController namaBahanController = TextEditingController();
  TextEditingController jumlahPermintaanController = TextEditingController();
  TextEditingController satuanController = TextEditingController();

   @override
  void initState(){
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => MaterialReceiveBloc(),
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
                PurchaseRequestDropDown(selectedPurchaseRequest: selectedNomorPermintaan, onChanged: (newValue) {
                      setState(() {
                        selectedNomorPermintaan = newValue??'';
                      });
                  }, jumlahPermintaanController: jumlahPermintaanController,
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: SupplierDropdown(
                      selectedSupplier: selectedSupplier,
                      kodeSupplierController: kodeSupplierController,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSupplier = newValue;
                          print(selectedSupplier);
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
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child:  BahanDropdown(namaBahanController: namaBahanController, bahanId: widget.materialId,)
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
                        label: 'Jumlah Permintaan',
                        placeholder: 'Jumlah Permintaan',
                        isEnabled: false,
                        controller: jumlahPermintaanController,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: 
                     TextFieldWidget(
                        label: 'Satuan',
                        placeholder: 'Kg',
                        isEnabled: false,
                        controller: satuanController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Jumlah Diterima',
                  placeholder: 'Jumlah Diterima',
                  controller: jumlahDiterimaController,
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
