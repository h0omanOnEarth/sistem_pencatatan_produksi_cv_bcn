import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/billofmaterialdropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/machine_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPerintahProduksiScreen extends StatefulWidget {
  static const routeName = '/form_perintah_produksi_screen';
  final String? productionOrderId;
  final String? productId;

  const FormPerintahProduksiScreen({Key? key, this.productionOrderId, this.productId}) : super(key: key);
  
  
  @override
  State<FormPerintahProduksiScreen> createState() =>
      _FormPerintahProduksiScreenState();
}

class _FormPerintahProduksiScreenState extends State<FormPerintahProduksiScreen> {
  DateTime? _selectedTanggalRencana;
  DateTime? _selectedTanggalProduksi;
  DateTime? _selectedTanggalSelesai;
  String? selectedKodeProduk;
  String? selectedKodeBOM;
  String? selectedMesinMixer;
  String? selectedMesinSheet;
  String? selectedMesinCetak;

  TextEditingController namaProdukController = TextEditingController();
  TextEditingController jumlahProduksiController = TextEditingController();
  TextEditingController perkiraanLamaWaktuController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController jumlahTenagaKerjaController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  List<Map<String, dynamic>> productDataProduk = []; // Inisialisasi daftar produk

   void fetchData(){
    // Ambil data produk dari Firestore di initState
    firestore.collection('products').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> product = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
          'nama': doc['nama'] as String, // Ganti 'nama' dengan field yang sesuai di Firestore
        };
        setState(() {
          productDataProduk.add(product); // Tambahkan produk ke daftar produk
        });
      });
    });
  }

 @override
  void dispose() {
    selectedProdukNotifier.removeListener(_selectedKodeListener);
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKodeProduk = selectedProdukNotifier.value;
    });
  }

@override
void initState() {
  super.initState();
  selectedProdukNotifier.addListener(_selectedKodeListener);
  selectedKodeProduk = selectedProdukNotifier.value;
  fetchData();
}

  
@override
Widget build(BuildContext context) {
  final bool isBomSelected = selectedKodeBOM != null;
  return BlocProvider(
    create: (context) => ProductionOrderBloc(),
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
                  const SizedBox(width: 16.0),
                  const Flexible(
                      child: Text(
                        'Perintah Produksi',
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
                        label: 'Tanggal Rencana',
                        selectedDate: _selectedTanggalRencana,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalRencana = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DatePickerButton(
                        label: 'Tanggal Produksi',
                        selectedDate: _selectedTanggalProduksi,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalProduksi = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              DatePickerButton(
                        label: 'Tanggal Selesai',
                        selectedDate: _selectedTanggalSelesai,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalSelesai = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child:  ProdukDropDown(namaProdukController: namaProdukController)
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(child:
                   TextFieldWidget(
                      label: 'Nama Produk',
                      placeholder: 'Nama Produk',
                      controller: namaProdukController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BillOfMaterialDropDown(selectedBOM: selectedKodeBOM, onChanged: (newValue) {
                    setState(() {
                      selectedKodeBOM = newValue;
                    });
              },),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Jumlah Produksi (est)',
                      placeholder: '0',
                      controller: jumlahProduksiController,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Perkiraan Lama Waktu',
                      placeholder: '120m',
                      controller: perkiraanLamaWaktuController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                    label: 'Jumlah Tenaga Kerja (est)',
                    placeholder: 'Jumlah Tenaga Kerja',
                    controller: jumlahTenagaKerjaController,
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
               const Text(
                'Instruksi Produksi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              CustomCard(
                content: [
                  CustomCardContent(text: '1. Campur bahan recycle dan biji plastik PP.'),
                  CustomCardContent(text: '2. Ekstruksi dan Bentuk PP Sheet.'),
                  CustomCardContent(text: '3. Cetak PP Sheet menjadi gelas plastik'),
                  CustomCardContent(text: '4. Uji kualitas dan pengemasan'),
                ],
              ),
              const SizedBox(height: 16.0,),
              const Text(
                'Mesin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              MachineDropdown(selectedMachine: selectedMesinMixer, onChanged: (newValue) {
                    setState(() {
                      selectedMesinMixer = newValue;
                    });
              }, title: 'Mesin Pencampur',),
            const SizedBox(height: 16.0,),
            MachineDropdown(selectedMachine: selectedMesinSheet, onChanged: (newValue) {
                    setState(() {
                      selectedMesinSheet = newValue;
                    });
              }, title: 'Mesin Sheet',),
            const SizedBox(height: 16.0,),
             MachineDropdown(selectedMachine: selectedMesinCetak, onChanged: (newValue) {
                    setState(() {
                      selectedMesinCetak = newValue;
                    });
              }, title: 'Mesin Cetak',),
              const SizedBox(height: 16.0,),
             if (isBomSelected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bahan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0,),
                  FutureBuilder<QuerySnapshot>(
                    future: firestore
                        .collection('bill_of_materials')
                        .doc(selectedKodeBOM)
                        .collection('detail_bill_of_materials')
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('Tidak ada data bahan.');
                      }

                      final List<CustomCard> customCards = [];

                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        customCards.add(
                          CustomCard(
                            content: [
                              CustomCardContent(text: 'Kode Bahan: ${data['material_id'] ?? ''}'),
                              CustomCardContent(text: 'Jumlah: ${data['jumlah'].toString()}'),
                              CustomCardContent(text: 'Satuan: ${data['satuan'] ?? ''}'),
                              CustomCardContent(text: 'Batch: ${data['batch'] ?? ''}'),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: customCards.length,
                        itemBuilder: (context, index) {
                          return customCards[index];
                        },
                      );
                    },
                  ),
                ],
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
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
  )
  );
}
}

