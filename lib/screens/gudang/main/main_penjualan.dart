import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_customer_order_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainPenjualanGudangScreen extends StatefulWidget {
  static const routeName = '/gudang/penjualan';
  const MainPenjualanGudangScreen({Key? key});

  @override
  State<MainPenjualanGudangScreen> createState() => _MainPenjualanGudangScreenState();
}

class _MainPenjualanGudangScreenState extends State<MainPenjualanGudangScreen> {
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
                    const CardItem(icon: Icons.location_on_sharp, textA: 'Surat Jalan', textB: 'Memodifikasi dan melihat surat jalan', pageRoute: ListSuratJalan.routeName),
                    const CardItem(icon: Icons.shopping_cart_checkout, textA: 'Pengembalian Barang', textB: 'Memodifikasi dan melihat pengembalian barang', pageRoute: ListCustomerOrderReturn.routeName),
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

