import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainPembelianAdministrasiScreen extends StatefulWidget {
  static const routeName = '/main_pembelian_administrasi';
  const MainPembelianAdministrasiScreen({Key? key});

  @override
  State<MainPembelianAdministrasiScreen> createState() => _MainMasterAdministrasiScreenState();
}

class _MainMasterAdministrasiScreenState extends State<MainPembelianAdministrasiScreen> {
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
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20.0),
                          child: const Text(
                            'Pembelian',
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
                    const CardItem(icon: Icons.point_of_sale, textA: 'Pesanan Pembelian', textB: 'Memodifikasi dan melihat pesanan pembelian', pageRoute: ListPesananPembelian.routeName),
                    const CardItem(icon: Icons.shopping_cart_checkout, textA: 'Pesanan Pengembalian', textB: 'Memodifikasi dan melihat pesanan pengembalian', pageRoute: ListPesananPengembalianPembelian.routeName),
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
