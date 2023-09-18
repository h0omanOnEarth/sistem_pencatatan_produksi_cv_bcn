import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_mesin_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/billofmaterialdropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/machine_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
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
  TextEditingController statusController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  List<Map<String, dynamic>> productDataProduk = []; // Inisialisasi daftar produk
  List<Map<String, dynamic>> billOfMaterialsData = []; // Initialize the list
  Map<String, dynamic> mesinPencampuran = {};
  Map<String, dynamic> mesinSheet = {};
  Map<String, dynamic> mesinPencetak = {}; 
   
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

void initializeProduct(){
  selectedKodeProduk = widget.productId;
  _selectedKodeListener();
  firestore
  .collection('products')
  .where('id', isEqualTo: selectedKodeProduk) // Gunakan .where untuk mencocokkan ID
  .get()
  .then((QuerySnapshot querySnapshot) {
  if (querySnapshot.docs.isNotEmpty) {
    final productData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    final productName = productData['nama'];
    namaProdukController.text = productName ?? '';
  } else {
    print('Document does not exist on Firestore');
  }
}).catchError((error) {
  print('Error getting document: $error');
});
}

void fetchMachines(){
  firestore
      .collection('production_orders')
      .doc(widget.productionOrderId!) // Menggunakan widget.customerOrderId
      .collection('detail_machines') // Ganti dengan nama collection yang sesuai
      .get()
      .then((querySnapshot) {
    querySnapshot.docs.forEach((doc) async {
      final detailData = doc.data() as Map<String, dynamic>;
      if(detailData['batch']=='Pencampuran'){
        mesinPencampuran = {
          'batch' : 'Pencampuran',
          'machine_id' : detailData['machine_id']
        };
         setState(() {
          selectedMesinMixer = detailData['machine_id'];
        });
      }else if(detailData['batch']=='Sheet'){
        mesinSheet = {
          'batch' : 'Sheet',
          'machine_id' : detailData['machine_id']
        };
        setState(() {
          selectedMesinSheet = detailData['machine_id'];
        });
      }else{
        mesinPencetak = {
          'batch' : 'Pencetakan',
          'machine_id' : detailData['machine_id']
        };
        setState(() {
          selectedMesinCetak = detailData['machine_id'];
        });
      }
    });
  });
}

@override
void initState() {
  super.initState();
  selectedProdukNotifier.addListener(_selectedKodeListener);
  selectedKodeProduk = selectedProdukNotifier.value;
  fetchData();

  if(widget.productionOrderId!=null){
        firestore.collection('production_orders').doc(widget.productionOrderId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          jumlahProduksiController.text = data['jumlah_produksi_est'].toString();
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_pro'];
          jumlahTenagaKerjaController.text = data['jumlah_tenaga_kerja_est'].toString();
          perkiraanLamaWaktuController.text = data['lama_waktu_est'].toString();
          final tanggalProduksiFirestore = data['tanggal_produksi'];
          if (tanggalProduksiFirestore != null) {
            _selectedTanggalProduksi = (tanggalProduksiFirestore as Timestamp).toDate();
          }
          final tanggalRencanaFirestore = data['tanggal_rencana'];
          if (tanggalRencanaFirestore != null) {
            _selectedTanggalRencana = (tanggalRencanaFirestore as Timestamp).toDate();
          }
          final tanggalSelesaiFirestore = data['tanggal_selesai'];
          if (tanggalSelesaiFirestore != null) {
            _selectedTanggalSelesai = (tanggalSelesaiFirestore as Timestamp).toDate();
          }
          selectedKodeBOM = data['bom_id'];
          selectedKodeProduk = data['product_id'];
          fetchMachines();
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

   if(widget.productId!=null){
    initializeProduct();
  }

}

void addOrUpdate(){
   // ignore: no_leading_underscores_for_local_identifiers
   final _productionOrderBloc = BlocProvider.of<ProductionOrderBloc>(context);
   try{
    final productionOrder = ProductionOrder(id: '', bomId: selectedKodeBOM??'', jumlahProduksiEst: int.parse(jumlahProduksiController.text), jumlahTenagaKerjaEst: int.parse(jumlahTenagaKerjaController.text), lamaWaktuEst: int.parse(perkiraanLamaWaktuController.text), productId: selectedKodeProduk??'', status: 1, statusPro: statusController.text, tanggalProduksi: _selectedTanggalProduksi?? DateTime.now(), tanggalRencana: _selectedTanggalRencana ?? DateTime.now(), tanggalSelesai: _selectedTanggalSelesai ?? DateTime.now(), detailProductionOrderList: [], detailMesinProductionOrderList: []);

     for (var productCardData in billOfMaterialsData) {
      final detailProductionOrder = DetailProductionOrder(id: '', jumlahBOM: productCardData['jumlahBom'], materialId: productCardData['materialId'], productionOrderId: '', satuan: productCardData['satuan'], status: 1);
      productionOrder.detailProductionOrderList?.add(detailProductionOrder);
    }

    productionOrder.detailMesinProductionOrderList?.add(MachineDetail(batch: mesinPencampuran['batch'], id: '', machineId: mesinPencampuran['machine_id'], productionOrderId: '', status: 1));
    productionOrder.detailMesinProductionOrderList?.add(MachineDetail(batch: mesinSheet['batch'], id: '', machineId: mesinSheet['machine_id'], productionOrderId: '', status: 1));
    productionOrder.detailMesinProductionOrderList?.add(MachineDetail(batch: mesinPencetak['batch'], id: '', machineId: mesinPencetak['machine_id'], productionOrderId: '', status: 1));

    if(widget.productionOrderId!=null){
      _productionOrderBloc.add(UpdateProductionOrderEvent(widget.productionOrderId??'', productionOrder));
    }else{
      _productionOrderBloc.add(AddProductionOrderEvent(productionOrder));
    }

    _showSuccessMessageAndNavigateBack();
   }catch(e){
     // ignore: avoid_print
     print('Error: $e');
   }
}

void _showSuccessMessageAndNavigateBack() {
showDialog(
  context: context,
  builder: (BuildContext context) {
    return SuccessDialog(
      message: 'Berhasil menyimpan perintah produksi.',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}

void clearForm() {
  setState(() {
    _selectedTanggalRencana = null;
    _selectedTanggalProduksi = null;
    _selectedTanggalSelesai = null;
    selectedKodeProduk = null;
    selectedKodeBOM = null;
    selectedMesinMixer = null;
    selectedMesinSheet = null;
    selectedMesinCetak = null;

    namaProdukController.clear();
    jumlahProduksiController.clear();
    perkiraanLamaWaktuController.clear();
    catatanController.clear();
    jumlahTenagaKerjaController.clear();
    billOfMaterialsData.clear();
    mesinPencampuran.clear();
    mesinSheet.clear();
    mesinPencetak.clear();

    statusController.text = "Dalam Proses";
  });
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
                    child:  ProdukDropDown(namaProdukController: namaProdukController,productId: widget.productId,)
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
                      billOfMaterialsData.clear();
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
            TextFieldWidget(
                    label: 'Status',
                    placeholder: 'Dalam Proses',
                    isEnabled: false,
                    controller: statusController,
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
                      mesinPencampuran.clear();
                      mesinPencampuran = {
                        'batch' : 'Pencampuran',
                        'machine_id' : newValue,
                      };
                    });
              }, title: 'Pencampuran',),
            const SizedBox(height: 16.0,),
            MachineDropdown(selectedMachine: selectedMesinSheet, onChanged: (newValue) {
                    setState(() {
                      selectedMesinSheet = newValue;
                      mesinSheet.clear();
                      mesinSheet = {
                        'batch' : 'Sheet',
                        'machine_id' : newValue
                      };
                    });
              }, title: 'Sheet',),
            const SizedBox(height: 16.0,),
             MachineDropdown(selectedMachine: selectedMesinCetak, onChanged: (newValue) {
                    setState(() {
                      selectedMesinCetak = newValue;
                      mesinPencetak.clear();
                      mesinPencetak = {
                        'batch' : 'Pencetakan',
                        'machine_id' : newValue
                      };
                    });
              }, title: 'Cetak',),
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
                        return const Text('Tidak ada data bahan.');
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
                        Map<String, dynamic> billOfMaterial = {
                          'materialId': doc['material_id'], // Add fields you need
                          'jumlahBom': doc['jumlah'],
                          'satuan': doc['satuan'],
                          'batch': doc['batch'],
                        };
                        billOfMaterialsData.add(billOfMaterial); // Add to the list
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
                        addOrUpdate();
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
  )
  );
}
}

