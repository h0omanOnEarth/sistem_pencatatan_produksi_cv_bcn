import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_penggunaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_retur.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';

class MainLaporanAdministrasiScreen extends StatefulWidget {
  static const routeName = '/administrasi/laporan';
  const MainLaporanAdministrasiScreen({Key? key});

  @override
  State<MainLaporanAdministrasiScreen> createState() =>
      _MainMasterAdministrasiScreenState();
}

class _MainMasterAdministrasiScreenState
    extends State<MainLaporanAdministrasiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16)
                    .add(const EdgeInsets.only(top: 30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20.0),
                          child: const Text(
                            'Laporan',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle notification button press
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotifikasiScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CardItem(
                        icon: Icons.point_of_sale,
                        textA: 'Penggunaan Bahan Baku',
                        textB: 'Melihat laporan penggunaan bahan baku',
                        pageRoute: LaporanPenggunaanBahan.routeName),
                    const CardItem(
                        icon: Icons.shopping_cart_checkout,
                        textA: 'Barang Jadi Hasil Produksi',
                        textB: 'Melihat laporan barang hasil produksi',
                        pageRoute: LaporanBarang.routeName),
                    const CardItem(
                        icon: Icons.shopping_cart_checkout,
                        textA: 'Monitoring Pesanan Pelanggan',
                        textB: 'Melihat laporan pesanan pelanggan',
                        pageRoute: LaporanPesananPelanggan.routeName),
                    const CardItem(
                        icon: Icons.upload_file_sharp,
                        textA: 'Retur Barang',
                        textB: 'Melihat laporan retur barang',
                        pageRoute: LaporanReturBarang.routeName),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final IconData icon;
  final String textA;
  final String textB;
  final String pageRoute; // New property to specify the page route

  const CardItem({
    super.key,
    required this.icon,
    required this.textA,
    required this.textB,
    required this.pageRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routemaster.of(context).push(pageRoute);
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Set corner radius
          side: const BorderSide(
            color: Colors.grey, // Set border color
            width: 1.0, // Set border width
          ),
        ),
        child: Container(
          height: 100.0, // Set the desired height of the card
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 40.0, // Set the width for the icon
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    icon,
                    size: 36, // Customize the icon size
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textA,
                      style: const TextStyle(
                        fontSize: 18, // Customize the font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    Text(textB),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
