import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';

class HomeScreenProduksi extends StatefulWidget {
  static const routeName = '/home_screen_produksi';
  const HomeScreenProduksi({Key? key});

  @override
  State<HomeScreenProduksi> createState() => _HomeScreenProduksiState();
}

class _HomeScreenProduksiState extends State<HomeScreenProduksi> {
  final String userName = "John Doe"; // Ganti dengan nama pengguna yang sesuai
  final double totalDonation = 500000; // Ganti dengan jumlah donasi yang sesuai

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                          style: TextStyle(
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
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => NotifikasiScreen()),
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
    );
  }
}

class CardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: CardItem(
            "List ${index + 1}",
            ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"],
          ),
        );
      },
    );
  }
}

class CardItem extends StatelessWidget {
  final String title;
  final List<String> items;

  CardItem(this.title, this.items);

  @override
  Widget build(BuildContext context) {
   return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0), // Adjusted padding
      child: Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(item),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}