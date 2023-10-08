import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_home.dart';

class HomeScreenProduksi extends StatefulWidget {
  static const routeName = '/home_screen_produksi';
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
                            child: ClipOval( // Gunakan ClipOval untuk membuat gambar menjadi lingkaran
                              child: Image.asset(
                                'images/profile.jpg', // Ganti dengan nama file gambar profil yang sesuai
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
                  // CardList(), // Tampilkan tiga card dengan daftar di bawahnya
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
  final int maxItems = 5;

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
          final data = snapshot.data as Map<String, dynamic>;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final collectionName = data.keys.toList()[index];
              final collectionData = data[collectionName] as List<Map<String, dynamic>>;
              final items = collectionData.map((item) {
                final DateFormat dateFormat = DateFormat('dd MMMM y');
                String formattedDate = '';

                if (collectionName == 'material_requests') {
                  formattedDate = dateFormat.format(item['tanggal_permintaan'].toDate());
                } else if (collectionName == 'production_orders') {
                  formattedDate = dateFormat.format(item['tanggal_rencana'].toDate());
                } else if (collectionName == 'material_usages') {
                  formattedDate = dateFormat.format(item['tanggal_penggunaan'].toDate());
                }

                String statusText = '';
                if (item['status'] == 1) {
                  statusText = 'Aktif';
                } else if (item['status'] == 0) {
                  statusText = 'Tidak Aktif';
                }

                switch (collectionName) {
                  case 'products':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Stok: ${item['stok']}, Status: $statusText';
                  case 'materials':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Stok: ${item['stok']}, Status: $statusText';
                  case 'machines':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Tipe: ${item['tipe']}, Kondisi: ${item['kondisi']}, Status: $statusText';
                  case 'material_requests':
                    return 'ID: ${item['id']}, Tanggal Permintaan: $formattedDate, Jumlah: ${item['jumlah']}, Satuan: ${item['satuan']}, Status: ${item['status_mr']}';
                  case 'production_orders':
                    return 'ID: ${item['id']}, Tanggal Rencana: $formattedDate, Product ID: ${item['product_id']}, Status: ${item['status_pro']}';
                  case 'material_usages':
                    return 'ID: ${item['id']}, Tanggal Penggunaan: $formattedDate, Production Order ID: ${item['production_order_id']}, Status: ${item['status_mu']}';
                  default:
                    return '';
                }
              }).toList();

              while (items.length < maxItems) {
                items.add('');
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: CardItemHome(
                  collectionName,
                  items,
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> fetchFirestoreData() async {
    final firestore = FirebaseFirestore.instance;
    final collections = [
      'products',
      'materials',
      'machines',
      'material_requests',
      'production_orders',
      'material_usages',
    ];

    final data = <String, dynamic>{};

    for (final collectionName in collections) {
      final querySnapshot = await firestore.collection(collectionName).get();
      final collectionData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      data[collectionName] = collectionData;
    }

    return data;
  }
}
