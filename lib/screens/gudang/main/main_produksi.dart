import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pemindahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_penerimaan_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pengubahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainProduksiGudangScreen extends StatefulWidget {
  static const routeName = '/main_produksi_gudang';
  const MainProduksiGudangScreen({Key? key});

  @override
  State<MainProduksiGudangScreen> createState() => _MainMasterGudangScreenState();
}

class _MainMasterGudangScreenState extends State<MainProduksiGudangScreen> {
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
                            'Produksi',
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
                    const CardItem(icon: Icons.note_add, textA: 'Penerimaan Barang', textB: 'Memodifikasi dan melihat penerimaan barang', pageRoute: ListItemReceive.routeName),
                    const CardItem(icon: Icons.move_up_sharp, textA: 'Pemindahan Bahan', textB: 'Memodifikasi dan melihat pemindahan bahan', pageRoute: ListPemindahanBahan.routeName),
                    const CardItem(icon: Icons.transform, textA: 'Pengubahan Bahan', textB: 'Memodifikasi dan melihat pengubahan bahan', pageRoute: ListPengubahanBahan.routeName),
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
