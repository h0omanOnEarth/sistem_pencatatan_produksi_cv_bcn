import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transforms_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_transform.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/machineService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/machine_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPengubahanBahan extends StatefulWidget {
  static const routeName = '/form_pengubahan_bahan_screen';
  final String? materialTransformId;
  final String? machineId;

  const FormPengubahanBahan({Key? key, this.materialTransformId, this.machineId}) : super(key: key);
  
  @override
  State<FormPengubahanBahan> createState() =>
      _FormPengubahanBahanState();
}

class _FormPengubahanBahanState extends State<FormPengubahanBahan> {
  DateTime? _selectedDate;
  String? selectedKodeMesin;
  bool isLoading = false;

  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController jumlahHasilController = TextEditingController();
  TextEditingController totalPengubahanController = TextEditingController();
  TextEditingController namaMesinController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController satuanController = TextEditingController();
  TextEditingController satuanTotalController= TextEditingController();
  TextEditingController satuanJumlahHasilController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  final machineService = MachineService();

@override
void initState() {
  super.initState();
  satuanController.text = "Pcs";
  satuanJumlahHasilController.text = "Kg";
  satuanTotalController.text = "Sak";
  statusController.text = "Dalam Proses";

  if (widget.materialTransformId != null) {
    firestore.collection('material_transforms').doc(widget.materialTransformId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_mtf'];
            final tanggalPengubahanFirestore = data['tanggal_pengubahan'];
            if (tanggalPengubahanFirestore != null) {
              _selectedDate = (tanggalPengubahanFirestore as Timestamp).toDate();
            }
            selectedKodeMesin = data['machine_id'];
            jumlahController.text = data['jumlah_barang_gagal'].toString();
            jumlahHasilController.text = data['jumlah_hasil'].toString();
            totalPengubahanController.text = data['total_hasil'].toString();
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
  }

  if (widget.machineId != null) {
    _fetchMachineInfo();
  }
}

// Tambahkan metode async untuk mengambil data mesin
Future<void> _fetchMachineInfo() async {
  Map<String, dynamic> machineInfo = await machineService.fetchMachineInfo(widget.machineId ?? '');
  setState(() {
    namaMesinController.text = machineInfo['nama'] ?? '';
  });
}

  @override
  void dispose(){
    super.dispose();
  }

  void clearForm() {
  setState(() {
    catatanController.text = '';
    jumlahController.text = '';
    jumlahHasilController.text = '';
    totalPengubahanController.text = '';
    namaMesinController.text = '';
    _selectedDate = null;
    selectedKodeMesin = null;
  });
}

  void addOrUpdate(){
    final materialTransformBloc = BlocProvider.of<MaterialTransformsBloc>(context);
    final materialTransform = MaterialTransforms(id: '', catatan: catatanController.text, jumlahBarangGagal: int.tryParse(jumlahController.text)??0, jumlahHasil: int.tryParse(jumlahHasilController.text)??0, machineId: selectedKodeMesin??'', satuan: satuanController.text, satuanHasil: satuanJumlahHasilController.text, satuanTotalHasil: satuanTotalController.text, status: 1, statusMtf: statusController.text, tanggalPengubahan: _selectedDate??DateTime.now(), totalHasil: int.tryParse(totalPengubahanController.text)??0);

    if(widget.materialTransformId!=null){
      materialTransformBloc.add(UpdateMaterialTransformsEvent(widget.materialTransformId??'', materialTransform));
    }else{
      materialTransformBloc.add(AddMaterialTransformsEvent(materialTransform));
    }
}

void _showSuccessMessageAndNavigateBack() {
  showDialog(
  context: context,
  builder: (BuildContext context) {
    return SuccessDialog(
      message: 'Berhasil menyimpan pengubahan bahan',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}

@override
Widget build(BuildContext context) {
   return BlocListener<MaterialTransformsBloc, MaterialTransformsBlocState>(
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
                      const SizedBox(width: 16.0),
                      const Flexible(
                            child: Text(
                              'Pengubahan Bahan',
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
                            label: 'Tanggal Pengubahan',
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
                      Expanded(child:  
                        MachineDropdown(selectedMachine: selectedKodeMesin, onChanged: (newValue) {
                              setState(() {
                                selectedKodeMesin = newValue;
                              });
                        }, title: 'Penggiling', namaMesinController: namaMesinController,),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(child:
                      TextFieldWidget(
                          label: 'Nama Mesin',
                          placeholder: 'Nama Mesin',
                          isEnabled: false,
                          controller: namaMesinController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0,),
                  Row(
                  children: [
                    Expanded(child:  
                      TextFieldWidget(
                        label: 'Jumlah Barang Gagal',
                        placeholder: '0',
                        controller: jumlahController,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(child:
                      TextFieldWidget(
                        label: ' ',
                        placeholder: 'Pcs',
                        isEnabled: false,
                        controller: satuanController,
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 16.0,),
                  Row(
                  children: [
                    Expanded(child:  
                      TextFieldWidget(
                        label: 'Jumlah Hasil Pengubahan',
                        placeholder: '0',
                        controller: jumlahHasilController,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(child:
                      TextFieldWidget(
                        label: ' ',
                        placeholder: 'Kg',
                        isEnabled: false,
                        controller: satuanJumlahHasilController,
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Expanded(child:  
                      TextFieldWidget(
                          label: 'Total Pengubahan',
                          placeholder: '0',
                          controller: totalPengubahanController,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(child:
                      TextFieldWidget(
                          label: ' ',
                          placeholder: 'Kg',
                          isEnabled: false,
                          controller: satuanTotalController,
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

