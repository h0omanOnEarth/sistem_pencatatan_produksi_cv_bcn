import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreenProduksi extends StatefulWidget {
  static const routeName = '/produksi/home';
  const HomeScreenProduksi({Key? key});

  @override
  State<HomeScreenProduksi> createState() => _HomeScreenProduksiState();
}

class _HomeScreenProduksiState extends State<HomeScreenProduksi> {
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
                                // Aksi untuk tombol notifikasi
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
    return FutureBuilder(
      future: fetchFirestoreData(),
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

          if (!data.containsKey('production_orders') || !data.containsKey('material_usages')||
              !data.containsKey('products')) {
            return const Text('Data structure is incorrect');
          }

          final productionOrders = data['production_orders'] as List;
          final materialUsages = (data['material_usages'] as List).cast<Map<String, dynamic>>();
          final products = (data['products'] as List).cast<Map<String, dynamic>>();

          final productionOrdersInProcess =
              productionOrders.where((order) => order['status_pro'] == 'Dalam Proses').toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productionOrdersInProcess.length,
            itemBuilder: (context, index) {
              final productionOrder = productionOrdersInProcess[index];
              final productionOrderId = productionOrder['id'];

              final materialUsage = materialUsages.firstWhere(
                (usage) => usage['production_order_id'] == productionOrderId,
                orElse: () => {},
              );

              final productionOrderBatch =  materialUsage['batch'] ?? 'Pencampuran';

              final progressBarValue = calculateProgressBarValue(materialUsages, productionOrderId, productionOrderBatch);

              // Hitung persentase progress
              final percentage = (progressBarValue * 100).toInt();
              // Dapatkan nama produk dari product_id
              final productId = productionOrder['product_id'];
              final productData = products.firstWhere((product) => product['id'] == productId, orElse: () => {});
              final productName = productData['nama'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0,),
                            Text('Current Batch: $productionOrderBatch'),
                            const SizedBox(height: 8.0,),
                            Text('Product ID: ${productionOrder['product_id']}'),
                            const SizedBox(height: 8.0),
                            Text('Product: $productName'),
                            const SizedBox(height: 8.0,),  
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0), 
                              child: LinearProgressIndicator(
                                value: progressBarValue,
                                minHeight: 20,
                                backgroundColor: Colors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                ),
              );
            },
          );
        }
      },
    );
  }

  double calculateProgressBarValue(List<Map<String, dynamic>> materialUsages, String productionOrderId, String productionOrderBatch) {
    if (materialUsages.any((usage) => usage['production_order_id'] == productionOrderId && usage['batch'] == 'Pencetakan')) {
      return 0.9; // Jika batch 'Pencetakan' ada, progress bar 90%
    } else if (materialUsages.any((usage) => usage['production_order_id'] == productionOrderId && usage['batch'] == 'Sheet')) {
      return 0.6; // Jika batch 'Sheet' ada, progress bar 50%
    } else {
      return 0.3; // Jika keduanya tidak ada, progress bar 0%
    }
  }
}

Future<Map<String, dynamic>> fetchFirestoreData() async {
  final firestore = FirebaseFirestore.instance;
  final collections = [
    'production_orders',
    'material_usages',
    'products'
  ];

  final data = <String, dynamic>{};

  for (final collectionName in collections) {
    final querySnapshot = await firestore.collection(collectionName).get();
    final collectionData = querySnapshot.docs.map((doc) => doc.data()).toList();

    if (collectionName == 'production_orders') {
      // Filter production_orders dengan status_pro == 'Dalam Proses'
      final filteredProductionOrders = collectionData.where((order) => order['status_pro'] == 'Dalam Proses').toList();
      data[collectionName] = filteredProductionOrders;
    } else {
      data[collectionName] = collectionData;
    }
  }

  return data;
}
