import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainMasterProduksiScreen extends StatefulWidget {
  static const routeName = '/produksi/master';
  const MainMasterProduksiScreen({Key? key});

  @override
  State<MainMasterProduksiScreen> createState() => _MainMasterProduksiScreenState();
}

class _MainMasterProduksiScreenState extends State<MainMasterProduksiScreen> {
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
                            'Master',
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
                    const CardItem(icon: Icons.warehouse, textA: 'Master Bahan', textB: 'Memodifikasi dan melihat data bahan', pageRoute: '${ListMasterBahanScreen.routeName}?mode=3'),
                    const CardItem(icon: Icons.notes_rounded, textA: 'Master Bill of Material', textB: 'Memodifikasi dan melihat data BOM', pageRoute: ListBOMScreen.routeName),
                    const CardItem(icon: Icons.factory_outlined, textA: 'Master Mesin', textB: 'Memodifikasi dan melihat data mesin', pageRoute: '${ListMasterMesinScreen.routeName}?mode=3'),
                    const CardItem(icon: Icons.gif_box, textA: 'Master Barang', textB: 'Memodifikasi dan melihat data barang', pageRoute: '${ListMasterBarangScreen.routeName}?mode=3'),
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

