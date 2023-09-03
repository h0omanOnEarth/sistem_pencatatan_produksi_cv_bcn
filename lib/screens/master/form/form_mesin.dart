import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/mesin_bloc.dart' as MesinBloc;
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/machine.dart';

class FormMasterMesinScreen extends StatefulWidget {
  static const routeName = '/form_master_mesin_screen';

  const FormMasterMesinScreen({Key? key}) : super(key: key);

  @override
  State<FormMasterMesinScreen> createState() => _FormMasterMesinScreenState();
}

class _FormMasterMesinScreenState extends State<FormMasterMesinScreen> {
  String selectedTipe = "Penggiling";
  String selectedSupplier = "";
  String selectedKondisi = "Baru";
  String selectedStatus = "Aktif";
  String selectedSatuan = "Kg";

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorSeriController = TextEditingController();
  final TextEditingController kapasitasController = TextEditingController();
  final TextEditingController tahunPembutanController = TextEditingController();
  final TextEditingController tahunPerolehanController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  final MesinBloc.MesinBloc _machineBloc = MesinBloc.MesinBloc();


  @override
  void dispose() {
    _machineBloc.close();
    super.dispose();
  }

  void addMachine() {
    final Mesin newMachine = Mesin(
      kapasitasProduksi: int.parse(kapasitasController.text),
      keterangan: catatanController.text,
      kondisi: selectedKondisi,
      nama: namaController.text,
      nomorSeri: nomorSeriController.text,
      satuan: selectedSatuan,
      status: selectedStatus == 'Aktif' ? 1 : 0,
      supplierId: selectedSupplier, // Sesuaikan dengan ID supplier yang dipilih
      tahunPembuatan: int.parse(tahunPembutanController.text),
      tahunPerolehan: int.parse(tahunPerolehanController.text),
      tipe: selectedTipe,
    );

    final MesinBloc.AddMesinEvent addEvent = MesinBloc.AddMesinEvent(newMachine);
    _machineBloc.add(addEvent);

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
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
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
                    const Text(
                      'Mesin',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Nama Mesin',
                  placeholder: 'Nama',
                  controller: namaController,
                ),
                const SizedBox(height: 16.0),
                DropdownWidget(
                  label: 'Tipe',
                  selectedValue: selectedTipe,
                  items: const ['Penggiling', 'Pencampur', 'Pencetak', 'Sheet'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedTipe = newValue;
                      print('Selected value: $newValue');
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Nomor Seri',
                  placeholder: 'Nomor Seri',
                  controller: nomorSeriController,
                ),
                const SizedBox(height: 16.0),
                Row(
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
                            print('Selected value: $newValue');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
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
                ),
                const SizedBox(height: 16.0),
                Builder(
                  builder: (context) {
                    final supplierBloc = context.read<SupplierBloc>();
                    return DropdownWidget(
                      label: 'Supplier',
                      selectedValue: selectedSupplier,
                      items: supplierBloc.state is LoadedState
                          ? (supplierBloc.state as LoadedState)
                              .suppliers
                              .map((supplier) => supplier.nama)
                              .toList()
                          : [],
                      onChanged: (newValue) {
                        final selectedSupplierObject =
                            (supplierBloc.state as LoadedState)
                                .suppliers
                                .firstWhere(
                                    (supplier) => supplier.nama == newValue);
                        setState(() {
                          selectedSupplier = selectedSupplierObject.supplierId ?? ''; // Memberikan nilai default jika null
                          print('Selected value: $selectedSupplier');
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                  multiline: true,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                        label: 'Status',
                        selectedValue: selectedStatus,
                        items: ['Aktif', 'Tidak Aktif'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue;
                            print('Selected value: $newValue');
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                        label: 'Kondisi',
                        selectedValue: selectedKondisi,
                        items: ['Baru', 'Bekas'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedKondisi = newValue;
                            print('Selected value: $newValue');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle save button press
                          addMachine(); // Panggil method addMachine saat tombol "Simpan" ditekan
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
                          namaController.clear();
                          nomorSeriController.clear();
                          kapasitasController.clear();
                          tahunPembutanController.clear();
                          tahunPerolehanController.clear();
                          catatanController.clear();
                          selectedTipe = "Penggiling";
                          selectedSupplier = "Supplier 1";
                          selectedKondisi = "Baru";
                          selectedStatus = "Aktif";
                          selectedSatuan = "Kg";
                          setState(() {});
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
    );
  }
}
