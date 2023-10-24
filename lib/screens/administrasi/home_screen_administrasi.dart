import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/customerOrderChart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/materialUsageChart.dart';


class HomeScreenAdministrasi extends StatefulWidget {
  static const routeName = '/administrasi/home';
  const HomeScreenAdministrasi({Key? key});

  @override
  State<HomeScreenAdministrasi> createState() => _HomeScreenAdministrasiState();
}

class _HomeScreenAdministrasiState extends State<HomeScreenAdministrasi> {
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
                                "$userName",
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
                    collectionName: 'customer_orders',
                    statusField: 'status_pesanan',
                    statusValue: 'Dalam Proses',
                    idField: 'id',
                    title: 'Pesanan Pelanggan',
                  ),),
                  SizedBox(height: 16), // Tambahkan jarak antara card
                  Expanded(child: CombinedCard(
                    collectionName: 'delivery_orders',
                    statusField: 'status_pesanan_pengiriman',
                    statusValue: 'Dalam Proses',
                    idField: 'id',
                    title: 'Perintah Pengiriman',
                  ),)
                  ],
                  ),
                  Row(
                    children: [
                      Expanded(child: CustomerOrderChart()),
                      const SizedBox(width: 8.0,),
                      Expanded(child: MaterialUsageChartCard())
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

  const CombinedCard({
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
                      Text('ID: ${itemData['id']}'),
                      Text('Total Barang: ${itemData['total_barang']}'),
                      Text('Total Harga: ${itemData['total_harga']}'),
                      // Tambahan sesuai dengan koleksi (customer_orders atau delivery_orders)
                      if (collectionName == 'customer_orders')
                        Text('Customer ID: ${itemData['customer_id']}'),
                      if (collectionName == 'delivery_orders')
                        Text('Customer Order ID: ${itemData['customer_order_id']}'),
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
    if (collectionName == 'customer_orders') {
      final customerID = doc['customer_id'] as String;
      final orderDate = doc['tanggal_pesan'] as Timestamp;
      final totalProducts = doc['total_produk'] as int;
      final totalPrice = doc['total_harga'] as double;
      return {
        'id': doc[idField] as String,
        'customer_id': customerID,
        'tanggal_pesan': DateFormat('dd/MM/yyyy').format(orderDate.toDate()), // Format the date
        'total_produk': totalProducts.toString(),
        'total_harga': totalPrice.toStringAsFixed(2),
      };
    } else if (collectionName == 'delivery_orders') {
      final customerOrderID = doc['customer_order_id'] as String;
      final deliveryDate = doc['tanggal_pesanan_pengiriman'] as Timestamp;
      final totalItems = doc['total_barang'] as int;
      final totalPrice = doc['total_harga'] as double;
      return {
        'id': doc[idField] as String,
        'customer_order_id': customerOrderID,
        'tanggal_pesanan_pengiriman': DateFormat('dd/MM/yyyy').format(deliveryDate.toDate()), // Format the date
        'total_barang': totalItems.toString(),
        'total_harga': totalPrice.toStringAsFixed(2),
      };
    }
    return {};
  }).toList();
  return data;
}

