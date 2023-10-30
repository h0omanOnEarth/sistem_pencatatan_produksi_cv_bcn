import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_delivery_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_faktur_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_pesanan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainPenjulanAdministrasiScreen extends StatefulWidget {
  static const routeName = '/administrasi/penjualan';
  const MainPenjulanAdministrasiScreen({Key? key});

  @override
  State<MainPenjulanAdministrasiScreen> createState() =>
      _MainMasterAdministrasiScreenState();
}

class _MainMasterAdministrasiScreenState
    extends State<MainPenjulanAdministrasiScreen> {
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
                            'Penjualan',
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
                        textA: 'Pesanan Pelanggan',
                        textB: 'Memodifikasi dan melihat pesanan pelanggan',
                        pageRoute: ListPesananPelanggan.routeName),
                    const CardItem(
                        icon: Icons.local_shipping,
                        textA: 'Pesanan Pengiriman',
                        textB:
                            'Memodifikasi dan melihat data pesanan pengiriman',
                        pageRoute: ListPesananPengiriman.routeName),
                    const CardItem(
                        icon: Icons.file_present_rounded,
                        textA: 'Faktur',
                        textB: 'Memodifikasi dan melihat data faktur',
                        pageRoute: ListFakturPenjualan.routeName),
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
