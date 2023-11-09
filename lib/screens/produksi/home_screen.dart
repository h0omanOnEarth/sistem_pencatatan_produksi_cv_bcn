import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/homeService.dart';

class HomeScreenProduksi extends StatefulWidget {
  static const routeName = '/produksi/home';
  const HomeScreenProduksi({Key? key});

  @override
  State<HomeScreenProduksi> createState() => _HomeScreenProduksiState();
}

class _HomeScreenProduksiState extends State<HomeScreenProduksi> {
  String? userName;

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
              child: Column(
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotifikasiScreen(),
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
                  const CardList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardList extends StatelessWidget {
  const CardList({Key? key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Perintah Produksi On Process',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: FutureBuilder(
              future: HomeService().fetchFirestoreData(
                  ['production_orders', 'material_usages', 'products']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                      'Jumlah On Process: Loading...'); // Menampilkan pesan "Loading..." selama data dimuat.
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data == null) {
                    return const Text('Data is null');
                  }

                  final data = snapshot.data as Map<String, dynamic>;
                  if (data.containsKey('production_orders_count')) {
                    final productionOrdersCount =
                        data['production_orders_count'] as int;
                    return Text(
                      'Jumlah On Process: $productionOrdersCount',
                      style: const TextStyle(
                        fontSize: 18, // Sesuaikan ukuran teks sesuai kebutuhan.
                      ),
                    );
                  } else {
                    return const Text('Data structure is incorrect');
                  }
                }
              },
            ),
          ),
          FutureBuilder(
            future: HomeService().fetchFirestoreData(
                ['production_orders', 'material_usages', 'products']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.data == null) {
                  return const Text('Data is null');
                }

                final data = snapshot.data as Map<String, dynamic>;

                if (!data.containsKey('production_orders') ||
                    !data.containsKey('material_usages') ||
                    !data.containsKey('products')) {
                  return const Text('Data structure is incorrect');
                }

                final productionOrders = data['production_orders'] as List;
                final materialUsages = (data['material_usages'] as List)
                    .cast<Map<String, dynamic>>();
                final products =
                    (data['products'] as List).cast<Map<String, dynamic>>();

                final productionOrdersInProcess = productionOrders
                    .where((order) => order['status'] == 1)
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: productionOrdersInProcess.length,
                  itemBuilder: (context, index) {
                    final productionOrder = productionOrdersInProcess[index];
                    final productionOrderId = productionOrder['id'];

                    final productionOrderBatch =
                        findBatch(materialUsages, productionOrderId);

                    final progressBarValue = calculateProgressBarValue(
                      materialUsages,
                      productionOrderId,
                    );

                    // Hitung persentase progress
                    final percentage = (progressBarValue * 100).toInt();
                    // Dapatkan nama produk dari product_id
                    final productId = productionOrder['product_id'];
                    final productData = products.firstWhere(
                        (product) => product['id'] == productId,
                        orElse: () => {});
                    final productName = productData['nama'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFCCCCCC),
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'ID: ${productionOrder['id']}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8.0),
                                      Text(
                                          'Current Batch: $productionOrderBatch'),
                                      const SizedBox(height: 8.0),
                                      Text(
                                          'Product ID: ${productionOrder['product_id']}'),
                                      const SizedBox(height: 8.0),
                                      Text('Product: $productName'),
                                      const SizedBox(height: 8.0),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: LinearProgressIndicator(
                                          value: progressBarValue,
                                          minHeight: 20,
                                          backgroundColor: Colors.grey,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Text('$percentage% Complete'),
                                ),
                              ],
                            ),
                          )),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  double calculateProgressBarValue(
      List<Map<String, dynamic>> materialUsages, String productionOrderId) {
    if (materialUsages.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Pencetakan')) {
      return 0.9; // Jika batch 'Pencetakan' ada, progress bar 90%
    } else if (materialUsages.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Sheet')) {
      return 0.6; // Jika batch 'Sheet' ada, progress bar 50%
    } else {
      return 0.3; // Jika keduanya tidak ada, progress bar 0%
    }
  }

  String findBatch(
      List<Map<String, dynamic>> materialUsages, String productionOrderId) {
    if (materialUsages.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Pencetakan')) {
      return 'Pencetakan'; // Jika batch 'Pencetakan' ada, progress bar 90%
    } else if (materialUsages.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Sheet')) {
      return 'Sheet'; // Jika batch 'Sheet' ada, progress bar 50%
    } else {
      return 'Pencampuran'; // Jika keduanya tidak ada, progress bar 0%
    }
  }
}
