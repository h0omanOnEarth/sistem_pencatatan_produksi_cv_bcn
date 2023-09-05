import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/mesin_bloc.dart' as MesinBloc;
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/machine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/form_master_mesin_screen';

  final String? mesinId;
  const FormMasterMesinScreen({Key? key, this.mesinId}) : super(key: key);

  @override
  State<FormMasterMesinScreen> createState() => _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String selectedTipe = "Penggiling";
  String? selectedSupplier;
  String selectedKondisi = "Baru";
  String selectedStatus = "Aktif";
  String selectedSatuan = "Kg";

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

  void addMachine() {
    final machineBloc = BlocProvider.of<MesinBloc.MesinBloc>(context);
    final Mesin newMachine = Mesin(
      id: '',
      kapasitasProduksi: int.parse(kapasitasController.text),
      keterangan: catatanController.text,
      kondisi: selectedKondisi,
      nama: namaController.text,
      nomorSeri: nomorSeriController.text,
      satuan: selectedSatuan,
      status: selectedStatus == 'Aktif' ? 1 : 0,
      supplierId: selectedSupplier ?? '',
      tahunPembuatan: int.parse(tahunPembutanController.text),
      tahunPerolehan: int.parse(tahunPerolehanController.text),
      tipe: selectedTipe,
    );

    machineBloc.add(MesinBloc.AddMesinEvent(newMachine));

    _showSuccessMessageAndNavigateBack();
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Berhasil menyimpan mesin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MesinBloc.MesinBloc(),
      child: Scaffold(
        body: SafeArea(
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
                  buildTextField('Nomor Seri', 'Nomor Seri', nomorSeriController),
                  const SizedBox(height: 16.0),
                  buildKapasitasSatuanRow(),
                  const SizedBox(height: 16.0),
                  buildTahunRow(),
                  const SizedBox(height: 16.0),
                  buildSupplierDropdown(),
                  const SizedBox(height: 16.0),
                  buildTextField('Catatan', 'Catatan', catatanController, multiline: true),
                  const SizedBox(height: 16.0),
                  buildStatusKondisiRow(),
                  const SizedBox(height: 24.0),
                  buildSimpanBersihkanButtons(),
                  buildErrorSnackbar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
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

  Widget buildTextField(String label, String placeholder, TextEditingController controller,
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
      items: const ['Penggiling', 'Pencampur', 'Pencetak', 'Sheet'],
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

  Widget buildSupplierDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> supplierItems = [];

        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          String supplierName = document['nama'] ?? '';
          String supplierId = document.id;
          supplierItems.add(
            DropdownMenuItem<String>(
              value: supplierId,
              child: Text(
                supplierName,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supplier',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSupplier,
                items: supplierItems,
                onChanged: (newValue) {
                  setState(() {
                    selectedSupplier = newValue;
                  });
                },
                isExpanded: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
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

  Widget buildErrorSnackbar() {
    return BlocBuilder<MesinBloc.MesinBloc, MesinBloc.MesinState>(
      builder: (context, state) {
        if (state is MesinBloc.ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
