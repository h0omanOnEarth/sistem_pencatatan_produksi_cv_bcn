import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_supplier_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainMasterAdministrasiScreen extends StatefulWidget {
  static const routeName = '/administrasi/master';
  const MainMasterAdministrasiScreen({Key? key});

  @override
  State<MainMasterAdministrasiScreen> createState() =>
      _MainMasterAdministrasiScreenState();
}

class _MainMasterAdministrasiScreenState
    extends State<MainMasterAdministrasiScreen> {
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
                    const CardItem(
                      icon: Icons.people,
                      textA: 'Master Pelanggan',
                      textB: 'Memodifikasi dan melihat data pelanggan',
                      pageRoute: ListMasterPelangganScreen.routeName,
                      pageWidget: ListMasterPelangganScreen(),
                    ),
                    const CardItem(
                      icon: Icons.emoji_people_sharp,
                      textA: 'Master Supplier',
                      textB: 'Memodifikasi dan melihat data supplier',
                      pageRoute: ListMasterSupplierScreen.routeName,
                      pageWidget: ListMasterSupplierScreen(),
                    ),
                    const CardItem(
                      icon: Icons.shopping_cart_checkout,
                      textA: 'Master Bahan',
                      textB: 'Memodifikasi dan melihat data bahan',
                      pageRoute: '${ListMasterBahanScreen.routeName}?mode=1',
                      pageWidget: ListMasterBahanScreen(),
                    ),
                    const CardItem(
                      icon: Icons.precision_manufacturing,
                      textA: 'Master Mesin',
                      textB: 'Memodifikasi dan melihat data mesin',
                      pageRoute: '${ListMasterMesinScreen.routeName}?mode=1',
                      pageWidget: ListMasterMesinScreen(),
                    ),
                    const CardItem(
                      icon: Icons.emoji_people_outlined,
                      textA: 'Master Pegawai',
                      textB: 'Memodifikasi dan melihat data pegawai',
                      pageRoute: ListMasterPegawaiScreen.routeName,
                      pageWidget: ListMasterPegawaiScreen(),
                    ),
                    const CardItem(
                      icon: Icons.warehouse,
                      textA: 'Master Barang',
                      textB: 'Memodifikasi dan melihat data barang',
                      pageRoute: '${ListMasterBarangScreen.routeName}?mode=1',
                      pageWidget: ListMasterBarangScreen(),
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
