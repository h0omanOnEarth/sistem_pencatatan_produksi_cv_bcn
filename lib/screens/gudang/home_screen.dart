import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/materialsChart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productsChartWidget.dart';

class HomeScreenGudang extends StatefulWidget {
  static const routeName = '/gudang/home';
  const HomeScreenGudang({Key? key});

  @override
  State<HomeScreenGudang> createState() => _HomeScreenGudangState();
}

class _HomeScreenGudangState extends State<HomeScreenGudang> {
 final String userName = "John Doe";

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(59, 51, 51, 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 70,
                        right: 10,
                        left: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: Image.asset(
                                'images/profile.jpg',
                                width: MediaQuery.of(context).size.width * 0.05,
                                height: MediaQuery.of(context).size.width * 0.05,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome Back,",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotifikasiScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Tambahkan jarak antara card dan konten di bawahnya
                  const Row(children: [
                    Expanded(child: CombinedCard(
                    collectionName: 'shipments',
                    statusField: 'status_shp',
                    statusValue: 'Dalam Proses',
                    idField: 'id',
                    title: 'Surat Jalan',
                  ),),
                  SizedBox(height: 16), // Tambahkan jarak antara card
                  Expanded(child: CombinedCard(
                    collectionName: 'purchase_requests',
                    statusField: 'status_prq',
                    statusValue: 'Dalam Proses',
                    idField: 'id',
                    title: 'Permintaan Pembelian',
                  ),)
                  ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: ProductsChart()),
                      const SizedBox(width: 8.0,),
                      Expanded(child: MaterialsChart())
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CombinedCard extends StatelessWidget {
  final String collectionName;
  final String statusField;
  final String statusValue;
  final String idField;
  final String title;

  const CombinedCard({super.key, 
    required this.collectionName,
    required this.statusField,
    required this.statusValue,
    required this.idField,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchFirestoreData(collectionName, statusField, statusValue, idField),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data as List<Map>;
          final itemCount = data.length; // Hitung jumlah data

          return Card(
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Border radius
              side: BorderSide(
                color: Colors.grey[300]!, // Border tipis grey400
              ),
            ),
            color: Colors.white,
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '$title On Process ($itemCount)', // Menambahkan jumlah data di dalam kurung
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3, // Atur tinggi card sesuai kebutuhan Anda
                  child: CardList(
                    collectionName: collectionName,
                    statusField: statusField,
                    statusValue: statusValue,
                    idField: idField,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}


class CardList extends StatelessWidget {
  final String collectionName;
  final String statusField;
  final String statusValue;
  final String idField;
  final int maxItems = 5;

  const CardList({
    required this.collectionName,
    required this.statusField,
    required this.statusValue,
    required this.idField,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchFirestoreData(collectionName, statusField, statusValue, idField),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final data = snapshot.data as List<Map>;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final itemData = data[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[400]!,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      Text('ID: ${itemData['id']}'), // Item yang cocok untuk semua koleksi
                      if (collectionName == 'shipments') ...[
                        Text('ID Perintah Pengiriman: ${itemData['delivery_order_id']}'),
                        Text('Total Barang: ${itemData['total_produk']}'),
                      ] else if (collectionName == 'purchase_requests') ...[
                        Text('ID Bahan: ${itemData['material_id']}'),
                        Text('Jumlah: ${itemData['jumlah']}'),
                        Text('Satuan: ${itemData['satuan']}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

Future<List<Map>> fetchFirestoreData(
  String collectionName, String statusField, String statusValue, String idField) async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection(collectionName).where(statusField, isEqualTo: statusValue).get();
  final data = querySnapshot.docs.map((doc) {
    if (collectionName == 'shipments') {
     final tanggalPembuatan = doc['tanggal_pembuatan'] as Timestamp;
      final totalProducts = doc['total_pcs'] as int;
      final deliveryOrderId = doc['delivery_order_id'] as String;
      return {
        'id': doc[idField] as String,
        'tanggal_pembuatan': DateFormat('dd/MM/yyyy').format(tanggalPembuatan.toDate()), // Format the date
        'total_produk': totalProducts.toString(),
        'delivery_order_id': deliveryOrderId,
      };
    } else if (collectionName == 'purchase_requests') {
      final materialId = doc['material_id'] as String;
      final tanggalPermintaan = doc['tanggal_permintaan'] as Timestamp;
      final jumlah = doc['jumlah'] as int;
      final satuan = doc['satuan'] as String;
      return {
        'id': doc[idField] as String,
        'material_id': materialId,
        'tanggal_permintaan': DateFormat('dd/MM/yyyy').format(tanggalPermintaan.toDate()), // Format the date
        'jumlah': jumlah.toString(),
        'satuan': satuan
      };
    }
    return {};
  }).toList();
  return data;
}
