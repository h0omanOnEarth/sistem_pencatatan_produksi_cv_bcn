import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/mesin_bloc.dart'
    as MesinBloc;
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/supplier_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/machine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/master/mesin/form';

  final String? mesinId;
  final String? supplierId;
  const FormMasterMesinScreen({Key? key, this.mesinId, this.supplierId})
      : super(key: key);

  @override
  State<FormMasterMesinScreen> createState() => _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String selectedTipe = "Penggiling";
  String? selectedSupplier;
  String selectedKondisi = "Baru";
  String selectedStatus = "Aktif";
  String selectedSatuan = "Kg";
  bool isLoading = false;

  TextEditingController namaController = TextEditingController();
  TextEditingController nomorSeriController = TextEditingController();
  TextEditingController kapasitasController = TextEditingController();
  TextEditingController tahunPembutanController = TextEditingController();
  TextEditingController tahunPerolehanController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  final MesinBloc.MesinBloc _machineBloc = MesinBloc.MesinBloc();

  @override
  void dispose() {
    _machineBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.mesinId != null) {
      FirebaseFirestore.instance
          .collection('machines')
          .where('id', isEqualTo: widget.mesinId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          setState(() {
            selectedStatus = data['status'] == 1 ? 'Aktif' : 'Tidak Aktif';
            namaController.text = data['nama'] ?? '';
            kapasitasController.text =
                data['kapasitas_produksi']?.toString() ?? '';
            catatanController.text = data['keterangan'] ?? '';
            selectedKondisi = data['kondisi'] ?? '';
            nomorSeriController.text = data['nomor_seri'] ?? '';
            selectedSatuan = data['satuan'] ?? '';
            tahunPembutanController.text =
                data['tahun_pembuatan']?.toString() ?? '';
            tahunPerolehanController.text =
                data['tahun_perolehan']?.toString() ?? '';
            selectedTipe = data['tipe'] ?? '';
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    // Periksa jika widget.supplierId tidak null
    if (widget.supplierId != null) {
      selectedSupplier = widget.supplierId;
    }
  }

  void addMachine() {
    final machineBloc = BlocProvider.of<MesinBloc.MesinBloc>(context);
    final Mesin newMachine = Mesin(
      id: '',
      kapasitasProduksi: int.tryParse(kapasitasController.text) ?? 0,
      keterangan: catatanController.text,
      kondisi: selectedKondisi,
      nama: namaController.text,
      nomorSeri: nomorSeriController.text,
      satuan: selectedSatuan,
      status: selectedStatus == 'Aktif' ? 1 : 0,
      supplierId: selectedSupplier ?? '',
      tahunPembuatan: int.tryParse(tahunPembutanController.text) ?? 0,
      tahunPerolehan: int.tryParse(tahunPerolehanController.text) ?? 0,
      tipe: selectedTipe,
    );

    if (widget.mesinId != null) {
      machineBloc
          .add(MesinBloc.UpdateMesinEvent(widget.mesinId ?? '', newMachine));
    } else {
      machineBloc.add(MesinBloc.AddMesinEvent(newMachine));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan Mesin',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MesinBloc.MesinBloc, MesinBloc.MesinState>(
      listener: (context, state) async {
        if (state is MesinBloc.SuccessState) {
          _showSuccessMessageAndNavigateBack();
          setState(() {
            isLoading = false; // Matikan isLoading saat successState
          });
        } else if (state is MesinBloc.ErrorState) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(errorMessage: state.errorMessage);
            },
          );
        } else if (state is MesinBloc.LoadingState) {
          setState(() {
            isLoading = true; // Aktifkan isLoading saat LoadingState
          });
        }

        // Hanya jika bukan LoadingState, atur isLoading ke false
        if (state is! MesinBloc.LoadingState) {
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
                      buildHeader(),
                      const SizedBox(height: 24.0),
                      buildTextField('Nama Mesin', 'Nama', namaController),
                      const SizedBox(height: 16.0),
                      buildTipeDropdown(),
                      const SizedBox(height: 16.0),
                      buildTextField(
                          'Nomor Seri', 'Nomor Seri', nomorSeriController),
                      const SizedBox(height: 16.0),
                      buildKapasitasSatuanRow(),
                      const SizedBox(height: 16.0),
                      buildTahunRow(),
                      const SizedBox(height: 16.0),
                      // Menggunakan SupplierDropdown
                      SupplierDropdown(
                        selectedSupplier: selectedSupplier,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSupplier = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      buildTextField('Catatan', 'Catatan', catatanController,
                          multiline: true),
                      const SizedBox(height: 16.0),
                      buildStatusKondisiRow(),
                      const SizedBox(height: 24.0),
                      buildSimpanBersihkanButtons(),
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
      ),
    );
  }

  Widget buildHeader() {
    return Row(
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
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 24.0),
        const Text(
          'Mesin',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
      String label, String placeholder, TextEditingController controller,
      {bool multiline = false}) {
    return TextFieldWidget(
      label: label,
      placeholder: placeholder,
      controller: controller,
      multiline: multiline,
    );
  }

  Widget buildTipeDropdown() {
    return DropdownWidget(
      label: 'Tipe',
      selectedValue: selectedTipe,
      items: const ['Penggiling', 'Pencampuran', 'Pencetak', 'Sheet'],
      onChanged: (newValue) {
        setState(() {
          selectedTipe = newValue;
        });
      },
    );
  }

  Widget buildKapasitasSatuanRow() {
    return Row(
      children: [
        Expanded(
          child: TextFieldWidget(
            label: 'Kapasitas Produksi',
            placeholder: 'Kapasitas Produksi',
            controller: kapasitasController,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: DropdownWidget(
            label: 'Satuan',
            selectedValue: selectedSatuan,
            items: const ['Kg', 'Ons', 'Pcs', 'Gram', 'Sak'],
            onChanged: (newValue) {
              setState(() {
                selectedSatuan = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildTahunRow() {
    return Row(
      children: [
        Expanded(
          child: TextFieldWidget(
            label: 'Tahun Pembuatan',
            placeholder: '20XX',
            controller: tahunPembutanController,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: TextFieldWidget(
            label: 'Tahun Perolehan',
            placeholder: '20XX',
            controller: tahunPerolehanController,
          ),
        ),
      ],
    );
  }

  Widget buildStatusKondisiRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownWidget(
            label: 'Status',
            selectedValue: selectedStatus,
            items: const ['Aktif', 'Tidak Aktif'],
            onChanged: (newValue) {
              setState(() {
                selectedStatus = newValue;
              });
            },
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: DropdownWidget(
            label: 'Kondisi',
            selectedValue: selectedKondisi,
            items: const ['Baru', 'Bekas', 'Baik', 'Buruk'],
            onChanged: (newValue) {
              setState(() {
                selectedKondisi = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildSimpanBersihkanButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              addMachine();
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
              clearFields();
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
    );
  }

  void clearFields() {
    namaController.clear();
    nomorSeriController.clear();
    kapasitasController.clear();
    tahunPembutanController.clear();
    tahunPerolehanController.clear();
    catatanController.clear();
    selectedTipe = "Penggiling";
    selectedSupplier = null;
    selectedKondisi = "Baru";
    selectedStatus = "Aktif";
    selectedSatuan = "Kg";
    setState(() {});
  }
}
