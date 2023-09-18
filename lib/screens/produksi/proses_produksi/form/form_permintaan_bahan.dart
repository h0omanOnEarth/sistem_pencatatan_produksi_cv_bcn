import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionorder_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPermintaanBahanScreen extends StatefulWidget {
  static const routeName = '/form_permintaan_bahan_screen';
  final String? productionOrderId;
  final String? materialRequestId;

  const FormPermintaanBahanScreen({Key? key, this.productionOrderId, this.materialRequestId}) : super(key: key);
  
  @override
  State<FormPermintaanBahanScreen> createState() =>
      _FormPermintaanBahanScreenState();
}

class _FormPermintaanBahanScreenState extends State<FormPermintaanBahanScreen> {
DateTime? _selectedTanggalPermintaan;
String? selectedNoPerintah;
bool isFirstTime = false;

TextEditingController tanggalProduksiController = TextEditingController();
TextEditingController catatanController = TextEditingController();
TextEditingController statusController  = TextEditingController();

final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
List<Map<String, dynamic>> materialDetailsData= []; // Initialize the list

Future<Map<String, dynamic>> fetchMaterialInfo(String materialId) async {
    final materialQuery = await firestore
    .collection('materials')
    .where('id', isEqualTo: materialId)
    .get();


  if (materialQuery.docs.isNotEmpty) {
    final materialData = materialQuery.docs.first.data();
    final materialName = materialData['nama'] as String? ?? '';
    final materialStock = materialData['stok'] as int? ?? 0;

    return {
      'nama': materialName,
      'stok': materialStock,
    };
  }

  return {
    'nama': '',
    'stok': 0,
  };
}

@override
void dispose() {
  super.dispose();
}

void initializeMaterial(){
  selectedNoPerintah = widget.productionOrderId;
  firestore
  .collection('production_orders')
  .where('id', isEqualTo: widget.productionOrderId) // Gunakan .where untuk mencocokkan ID
  .get()
  .then((QuerySnapshot querySnapshot) {
  if (querySnapshot.docs.isNotEmpty) {
    final materialData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    final tanggalProduksiFirestore = materialData['tanggal_produksi'];
    if (tanggalProduksiFirestore != null) {
      final timestamp = tanggalProduksiFirestore as Timestamp;
      final dateTime = timestamp.toDate();

      final List<String> monthNames = [
        "Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"
      ];

      final day = dateTime.day.toString();
      final month = monthNames[dateTime.month - 1];
      final year = dateTime.year.toString();

      final formattedDate = '$month $day, $year';
      tanggalProduksiController.text = formattedDate;
    }
  } else {
    print('Document does not exist on Firestore');
  }
}).catchError((error) {
  print('Error getting document: $error');
});
}

@override
void initState() {
  super.initState();
  statusController.text = "Dalam Proses";
  if(widget.materialRequestId!=null){
        firestore.collection('material_requests').doc(widget.materialRequestId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_mr'];
          final tanggalPermintaanFirestore = data['tanggal_permintaan'];
          if (tanggalPermintaanFirestore != null) {
            _selectedTanggalPermintaan = (tanggalPermintaanFirestore as Timestamp).toDate();
          }
          selectedNoPerintah = data['production_order_id'];
        });
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
    isFirstTime = true;
  }

   if(widget.productionOrderId!=null){
    initializeMaterial();
  }

}

void clearFields(){
  _selectedTanggalPermintaan = null;
  selectedNoPerintah = null;
  tanggalProduksiController.clear();
  catatanController.clear();
  materialDetailsData.clear();
  statusController.text = "Dalam Proses";
}

void addOrUpdate(){
final materialRequestBloc = BlocProvider.of<MaterialRequestBloc>(context);
try{
  final materialRequest = MaterialRequest(id: '', productionOrderId: selectedNoPerintah??'', status: 1, statusMr: catatanController.text, tanggalPermintaan:_selectedTanggalPermintaan??DateTime.now(), detailMaterialRequestList: []);

  for (var productCardData in materialDetailsData) {
      final detailMaterialRequest = DetailMaterialRequest(id: '', jumlahBom: productCardData['jumlah'], materialId: productCardData['materialId'], materialRequestId: '', satuan: productCardData['satuan'], batch: productCardData['batch'], status: 1);
      materialRequest.detailMaterialRequestList.add(detailMaterialRequest);
  }

  if(widget.materialRequestId!=null){
    materialRequestBloc.add(UpdateMaterialRequestEvent(widget.materialRequestId??'', materialRequest));
  }else{
    materialRequestBloc.add(AddMaterialRequestEvent(materialRequest));
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
      message: 'Berhasil menyimpan permintaan bahan.',
    );
  },
  ).then((_) {
    Navigator.pop(context,null);
  });
}


@override
Widget build(BuildContext context) {
  final bool isPROselected = selectedNoPerintah != null;
  return BlocProvider(
    create: (context) => MaterialRequestBloc(),
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
                          'Permintaan Bahan',
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
                        label: 'Tanggal Permintaan',
                        selectedDate: _selectedTanggalPermintaan,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPermintaan = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              ProductionOrderDropDown(selectedPRO: selectedNoPerintah, onChanged: (newValue) {
                    setState(() {
                      selectedNoPerintah = newValue??'';
                      materialDetailsData.clear();
                    });
              },tanggalProduksiController: tanggalProduksiController,),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Tanggal Produksi',
                placeholder: 'Tanggal Produksi',
                controller: tanggalProduksiController,
                isEnabled: false,
              ),
             const SizedBox(height: 16),
            TextFieldWidget(
                    label: 'Status',
                    placeholder: 'Dalam Proses',
                    isEnabled: false,
                    controller: statusController
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Catatan',
                placeholder: 'Catatan',
                controller: catatanController,
              ),
              const SizedBox(height: 16.0,),
              if (!isPROselected)
              const Text(
                'Detail Bahan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              if (!isPROselected)
              const Text(
                'Tidak ada detail bahan',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16.0,),
              if (isPROselected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Bahan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0,),
                    FutureBuilder<QuerySnapshot>(
                      future: (widget.materialRequestId != null && isFirstTime==true)
                      ? firestore
                          .collection('material_requests')
                          .doc(widget.materialRequestId)
                          .collection('detail_material_requests')
                          .get()
                      : firestore
                          .collection('production_orders')
                          .doc(selectedNoPerintah)
                          .collection('detail_production_orders')
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Tidak ada data detail bahan.');
                        }

                        final List<Widget> customCards = [];

                        for (final doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final materialId = data['material_id'] as String? ?? '';

                          Future<Map<String, dynamic>> materialInfoFuture = fetchMaterialInfo(materialId);

                          customCards.add(
                            FutureBuilder<Map<String, dynamic>>(
                              future: materialInfoFuture,
                              builder: (context, materialInfoSnapshot) {
                                if (materialInfoSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (materialInfoSnapshot.hasError) {
                                  return Text('Error: ${materialInfoSnapshot.error}');
                                }

                                final materialInfoData = materialInfoSnapshot.data ?? {};
                                final materialName = materialInfoData['nama'] as String;
                                final materialStock = materialInfoData['stok'] as int;

                                return CustomCard(
                                  content: [
                                    CustomCardContent(text: 'Kode Bahan: $materialId'),
                                    CustomCardContent(text: 'Nama: $materialName'),
                                    CustomCardContent(text: 'Jumlah: ${data['jumlah_bom'].toString()}'),
                                    CustomCardContent(text: 'Stok: $materialStock'), // Menampilkan stok di sini
                                    CustomCardContent(text: 'Satuan: ${data['satuan'] ?? ''}'),
                                  ],
                                );
                              },
                            ),
                          );
                          Map<String, dynamic> detailMaterial = {
                          'materialId': doc['material_id'], // Add fields you need
                          'jumlah': doc['jumlah_bom'],
                          'satuan': doc['satuan'],
                          'batch': doc['batch'],
                        };
                        materialDetailsData.add(detailMaterial); // Add to the list
                        isFirstTime = false;
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
                        clearFields();
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

