import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/dloh_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/dloh.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/material_usage_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPencatatanDirectLaborScreen extends StatefulWidget {
  static const routeName = '/form_pencatatan_DLOC_screen';
  final String? materialUsageId;
  final String? dlohId;

  const FormPencatatanDirectLaborScreen({Key? key, this.materialUsageId, this.dlohId}) : super(key: key);
  
  @override
  State<FormPencatatanDirectLaborScreen> createState() =>
      _FormPencatatanDirectLaborScreenState();
}

class _FormPencatatanDirectLaborScreenState extends State<FormPencatatanDirectLaborScreen> {
  DateTime? _selectedDate;
  String? selectedPenggunaanBahan;

  TextEditingController nomorPerintahProduksiController = TextEditingController();
  TextEditingController namaBatchController = TextEditingController();
  TextEditingController upahTenagaKerjaPerJamController = TextEditingController();
  TextEditingController jumlahTenagaKerjaController = TextEditingController();
  TextEditingController jumlahJamTenagaKerjaController = TextEditingController();
  TextEditingController biayaOverheadController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController totalBiayaController = TextEditingController();
  TextEditingController biayaTenagaKerjaController= TextEditingController();

   @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearForm() {
  setState(() {
    nomorPerintahProduksiController.text = '';
    namaBatchController.text = '';
    upahTenagaKerjaPerJamController.text = '';
    jumlahTenagaKerjaController.text = '';
    jumlahJamTenagaKerjaController.text = '';
    biayaOverheadController.text = '';
    catatanController.text = '';
    selectedPenggunaanBahan = null;
    _selectedDate = null;
    totalBiayaController.text = '';
    biayaTenagaKerjaController.text = '';
  });
}

void updateBiayaTenagaKerja() {
  // Ambil nilai dari controller yang relevan
  int jumlahJam = int.tryParse(jumlahJamTenagaKerjaController.text) ?? 0;
  int upahPerJam = int.tryParse(upahTenagaKerjaPerJamController.text) ?? 0;
  int jumlahTenagaKerja = int.tryParse(jumlahTenagaKerjaController.text) ?? 0;

  // Hitung biaya tenaga kerja
  int biayaTenagaKerjaDouble = jumlahJam * upahPerJam * jumlahTenagaKerja;
  int biayaTenagaKerja = biayaTenagaKerjaDouble.round(); // Ubah menjadi int

  // Format biaya tenaga kerja menjadi format mata uang Rupiah
  biayaTenagaKerjaController.text = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(biayaTenagaKerja);

  updateTotalBiaya();
}


void updateTotalBiaya() {
  // Ambil nilai dari controller yang relevan
  int biayaTenagaKerja = int.tryParse(biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int biayaOverhead = int.tryParse(biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  // Hitung total biaya
  int totalBiaya = biayaTenagaKerja + biayaOverhead;

  // Format total biaya menjadi format mata uang Rupiah
  totalBiayaController.text = NumberFormat.currency(
    locale: 'id_ID', // Atur locale ke ID untuk format Rupiah
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(totalBiaya);
}

  void addOrUpdate(){
    final dlohBloc =BlocProvider.of<DLOHBloc>(context);
    
    int biayaOverheadInt = int.tryParse(biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int biayaTenagaKerja = int.tryParse(biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int totalBiayaInt = int.tryParse(totalBiayaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final dloh = DLOH(id: '', materialUsageId: selectedPenggunaanBahan??'', tanggalPencatatan: _selectedDate??DateTime.now(), catatan: catatanController.text, status: 1, jumlahTenagaKerja: int.parse(jumlahTenagaKerjaController.text), jumlahJamTenagaKerja: int.parse(jumlahJamTenagaKerjaController.text), biayaTenagaKerja: biayaTenagaKerja, biayaOverhead: biayaOverheadInt, upahTenagaKerjaPerjam: int.parse(upahTenagaKerjaPerJamController.text), subtotal: totalBiayaInt);

    if(widget.dlohId!=null){
      dlohBloc.add(UpdateDLOHEvent(widget.dlohId??'', dloh));
    }else{
      dlohBloc.add(AddDLOHEvent(dloh));
    }

    _showSuccessMessageAndNavigateBack();

  }

void _showSuccessMessageAndNavigateBack() {
showDialog(
  context: context,
  builder: (BuildContext context) {
    return SuccessDialog(
      message: 'Berhasil menyimpan DLOHC',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => DLOHBloc(),
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
                       'Direct Labor and\nOverhead Costs',
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
                }, namaBatchController: namaBatchController, nomorPerintahProduksiController: nomorPerintahProduksiController,),
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
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jumlah Tenaga Kerja',
                        placeholder: 'Jumlah Tenaga Kerja',
                        controller: jumlahTenagaKerjaController,
                        onChanged: (value) {
                            // Ketika nilai berubah, panggil updateBiayaTenagaKerja
                            setState(() {
                              updateBiayaTenagaKerja();
                            });
                          },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Jum. Jam Tenaga Kerja',
                        placeholder: 'Jum. Jam Tenaga Kerja',
                        controller: jumlahJamTenagaKerjaController,
                         onChanged: (value) {
                            // Ketika nilai berubah, panggil updateBiayaTenagaKerja
                            setState(() {
                              updateBiayaTenagaKerja();
                            });
                          },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Upah Tenaga Kerja /Jam',
                        placeholder: 'Upah /jam',
                        controller: upahTenagaKerjaPerJamController,
                        onChanged: (value) {
                            // Ketika nilai berubah, panggil updateBiayaTenagaKerja
                            setState(() {
                              updateBiayaTenagaKerja();
                            });
                          },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextFieldWidget(
                        label: 'Biaya Tenaga Kerja',
                        placeholder: 'Biaya Tenaga Kerja',
                        isEnabled: false,
                        controller: biayaTenagaKerjaController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                    label: 'Biaya Overhead',
                    placeholder: 'Biaya Overhead',
                    controller: biayaOverheadController,
                     onChanged: (value) {
                      // Ketika nilai berubah, panggil updateTotalBiaya
                      setState(() {
                        updateTotalBiaya();
                      });
                    },
                ),
                const SizedBox(height: 16.0,),
                TextFieldWidget(
                    label: 'Total Biaya',
                    placeholder: 'Total Biaya',
                    isEnabled: false,
                    controller: totalBiayaController,
                ),
                const SizedBox(height: 16.0,),
                const TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  isEnabled: false,
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
                          // Handle save button pressa
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
    )
    );
  }
}
