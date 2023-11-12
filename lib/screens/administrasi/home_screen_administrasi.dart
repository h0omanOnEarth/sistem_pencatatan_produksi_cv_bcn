import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/customerOrderChart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/materialUsageChart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreenAdministrasi extends StatefulWidget {
  static const routeName = '/administrasi/home';
  const HomeScreenAdministrasi({Key? key});

  @override
  State<HomeScreenAdministrasi> createState() => _HomeScreenAdministrasiState();
}

class _HomeScreenAdministrasiState extends State<HomeScreenAdministrasi> {
  String? userName;
  String? posisi;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      getUserDetails(user.email ?? '');
    }
  }

  Future<void> getUserDetails(String email) async {
    final firestore = FirebaseFirestore.instance;
    final userRef =
        firestore.collection('employees').where('email', isEqualTo: email);
    final userSnapshot = await userRef.get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first;
      setState(() {
        userName = userData['nama'];
        posisi = userData['posisi'];
      });
    }
  }

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 600) {
                    // Wide Layout (Desktop/Tablet)
                    return buildWideLayout();
                  } else {
                    // Narrow Layout (Mobile)
                    return buildNarrowLayout();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Card
        Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userName ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
                    child: IconButton(
                      onPressed: () {
                        Routemaster.of(context).push(
                            '${NotifikasiScreen.routeName}?routeBack=${MainAdministrasi.routeName}?selectedIndex=0');
                      },
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // First Section Card
        const Row(
          children: [
            Expanded(
              child: CombinedCard(
                collectionName: 'customer_orders',
                statusField: 'status_pesanan',
                statusValue: 'Dalam Proses',
                idField: 'id',
                title: 'Pesanan Pelanggan',
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: CombinedCard(
                collectionName: 'delivery_orders',
                statusField: 'status_pesanan_pengiriman',
                statusValue: 'Dalam Proses',
                idField: 'id',
                title: 'Perintah Pengiriman',
              ),
            )
          ],
        ),

        // Second Section Card
        const Row(
          children: [
            Expanded(child: CustomerOrderChart()),
            SizedBox(width: 16),
            Expanded(child: MaterialUsageChartCard()),
          ],
        ),
      ],
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 5,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userName ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Add the position of the employee here
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white, // Adjust opacity as needed
                          ),
                          child: Text(
                            'Posisi: ${posisi ?? ''}', // Replace with the actual position
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
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
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CombinedCard(
          collectionName: 'customer_orders',
          statusField: 'status_pesanan',
          statusValue: 'Dalam Proses',
          idField: 'id',
          title: 'Pesanan Pelanggan',
        ),
        const SizedBox(height: 16),
        const CombinedCard(
          collectionName: 'delivery_orders',
          statusField: 'status_pesanan_pengiriman',
          statusValue: 'Dalam Proses',
          idField: 'id',
          title: 'Perintah Pengiriman',
        ),
        const CustomerOrderChart(),
        const SizedBox(height: 16),
        const MaterialUsageChartCard(),
        // Additional content goes here
      ],
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
    super.key,
    required this.collectionName,
    required this.statusField,
    required this.statusValue,
    required this.idField,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          fetchFirestoreData(collectionName, statusField, statusValue, idField),
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
                  height: MediaQuery.of(context).size.height *
                      0.3, // Atur tinggi card sesuai kebutuhan Anda
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
      future:
          fetchFirestoreData(collectionName, statusField, statusValue, idField),
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
            physics: const BouncingScrollPhysics(),
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
                      Text('Total Harga: ${itemData['total_harga']}'),
                      // Tambahan sesuai dengan koleksi (customer_orders atau delivery_orders)
                      if (collectionName == 'customer_orders')
                        Text('Total Barang: ${itemData['total_produk']}'),
                      if (collectionName == 'customer_orders')
                        Text('Customer ID: ${itemData['customer_id']}'),
                      if (collectionName == 'delivery_orders')
                        Text('Total Barang: ${itemData['total_barang']}'),
                      if (collectionName == 'delivery_orders')
                        Text(
                            'Customer Order ID: ${itemData['customer_order_id']}'),
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

Future<List<Map>> fetchFirestoreData(String collectionName, String statusField,
    String statusValue, String idField) async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore
      .collection(collectionName)
      .where(statusField, isEqualTo: statusValue)
      .get();
  final data = querySnapshot.docs.map((doc) {
    if (collectionName == 'customer_orders') {
      final customerID = doc['customer_id'] as String;
      final orderDate = doc['tanggal_pesan'] as Timestamp;
      final totalProducts = doc['total_produk'] as int;
      final totalPrice = doc['total_harga'] as int;
      return {
        'id': doc[idField] as String,
        'customer_id': customerID,
        'tanggal_pesan': DateFormat('dd/MM/yyyy')
            .format(orderDate.toDate()), // Format the date
        'total_produk': totalProducts.toString(),
        'total_harga': totalPrice.toStringAsFixed(2),
      };
    } else if (collectionName == 'delivery_orders') {
      final customerOrderID = doc['customer_order_id'] as String;
      final deliveryDate = doc['tanggal_pesanan_pengiriman'] as Timestamp;
      final totalItems = doc['total_barang'] as int;
      final totalPrice = doc['total_harga'] as int;
      return {
        'id': doc[idField] as String,
        'customer_order_id': customerOrderID,
        'tanggal_pesanan_pengiriman': DateFormat('dd/MM/yyyy')
            .format(deliveryDate.toDate()), // Format the date
        'total_barang': totalItems.toString(),
        'total_harga': totalPrice.toStringAsFixed(2),
      };
    }
    return {};
  }).toList();
  return data;
}
