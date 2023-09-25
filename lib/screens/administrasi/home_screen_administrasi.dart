import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import paket intl untuk memformat tanggal
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_home.dart';

class HomeScreenAdministrasi extends StatefulWidget {
  static const routeName = '/home_screen_administrasi';
  const HomeScreenAdministrasi({Key? key});

  @override
  State<HomeScreenAdministrasi> createState() => _HomeScreenAdministrasiState();
}

class _HomeScreenAdministrasiState extends State<HomeScreenAdministrasi> {
  final String userName = "John Doe"; // Ganti dengan nama pengguna yang sesuai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Stack(
      children: [
           // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.8), // Sesuaikan dengan kecerahan yang diinginkan
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          SafeArea(
          child:SingleChildScrollView(
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
                      child: IconButton(
                        onPressed: () {
                          // Aksi untuk tombol notifikasi
                        },
                        icon: const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 32,
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
            CardList(), // Tampilkan tiga card dengan daftar di bawahnya
          ],
        ),
      ),   
        )
      ],
    )
    );
  }
}

class CardList extends StatelessWidget {
  final int maxItems = 5; // Tentukan jumlah maksimal item yang ingin ditampilkan

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
            physics: const NeverScrollableScrollPhysics(), // Tidak bisa di-scroll
            itemCount: data.length,
            itemBuilder: (context, index) {
              final collectionName = data.keys.toList()[index];
              final collectionData = data[collectionName] as List<Map<String, dynamic>>;
              final items = collectionData.map((item) {
                // Sesuaikan ini dengan field yang berisi tanggal pada masing-masing koleksi
                final DateFormat dateFormat = DateFormat('dd MMMM y');
                String formattedDate = '';

                if (collectionName == 'customer_orders') {
                  formattedDate = dateFormat.format(item['tanggal_pesan'].toDate());
                } else if (collectionName == 'purchase_requests') {
                  formattedDate = dateFormat.format(item['tanggal_permintaan'].toDate());
                }
                
                // Sesuaikan dengan field yang ingin ditampilkan
                String statusText = '';
                if (item['status'] == 1) {
                  statusText = 'Aktif';
                } else if (item['status'] == 0) {
                  statusText = 'Tidak Aktif';
                }

                // Sesuaikan dengan field yang ingin ditampilkan
                switch (collectionName) {
                  case 'customer_orders':
                    return 'ID: ${item['id']}, Tanggal Pesan: $formattedDate, Customer ID: ${item['customer_id']}, Status: ${item['status_pesanan']}';
                  case 'products':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Stok: ${item['stok']}, Status: $statusText';
                  case 'materials':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Stok: ${item['stok']}, Status: $statusText';
                  case 'purchase_requests':
                    return 'ID: ${item['id']}, Tanggal Permintaan: $formattedDate, Jumlah: ${item['jumlah']}, Satuan: ${item['satuan']}, Status: ${item['status_prq']}';
                  case 'customers':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Status: $statusText';
                  case 'suppliers':
                    return 'ID: ${item['id']}, Nama: ${item['nama']}, Status: $statusText';
                  default:
                    return '';
                }
              }).toList();

              // Tambahkan item kosong hingga mencapai jumlah maksimal
              while (items.length < maxItems) {
                items.add('');
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Ubah padding
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
      'customer_orders',
      'products',
      'materials',
      'purchase_requests',
      'customers',
      'suppliers',
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


  Future<Map<String, dynamic>> fetchFirestoreData() async {
    final firestore = FirebaseFirestore.instance;
    final collections = [
      'customer_orders',
      'products',
      'materials',
      'purchase_requests',
      'customers',
      'suppliers',
    ];

    final data = <String, dynamic>{};

    for (final collectionName in collections) {
      final querySnapshot = await firestore.collection(collectionName).get();
      final collectionData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      data[collectionName] = collectionData;
    }

    return data;
  }

