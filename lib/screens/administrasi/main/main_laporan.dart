import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_penggunaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/laporan/laporan_retur.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

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
