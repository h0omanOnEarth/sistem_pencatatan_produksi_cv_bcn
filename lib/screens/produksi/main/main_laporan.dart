import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/laporan/laporan_kualitas_produk.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/laporan/laporan_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainLaporanProduksiScreen extends StatefulWidget {
  static const routeName = '/produksi/laporan';
  const MainLaporanProduksiScreen({Key? key});

  @override
  State<MainLaporanProduksiScreen> createState() =>
      _MainLaporanProduksiScreenState();
}

class _MainLaporanProduksiScreenState extends State<MainLaporanProduksiScreen> {
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
                            if (kIsWeb) {
                              Routemaster.of(context).push(
                                  '${NotifikasiScreen.routeName}?routeBack=${MainProduksi.routeName}?selectedIndex=3');
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotifikasiScreen(),
                                ),
                              );
                            }
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
                      icon: Icons.warehouse,
                      textA: 'Laporan Produksi Harian',
                      textB: 'Melihat laporan produksi harian',
                      pageRoute: LaporanProduksi.routeName,
                      pageWidget: LaporanProduksi(),
                    ),
                    const CardItem(
                      icon: Icons.notes_rounded,
                      textA: 'Laporan Kualitas Produk',
                      textB: 'Melihat laporan kualitas produk',
                      pageRoute: LaporanKualitasProduksi.routeName,
                      pageWidget: LaporanKualitasProduksi(),
                    ),
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
