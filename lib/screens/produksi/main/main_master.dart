import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/helper/notification_helper.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainMasterProduksiScreen extends StatefulWidget {
  static const routeName = '/produksi/master';
  const MainMasterProduksiScreen({Key? key});

  @override
  State<MainMasterProduksiScreen> createState() =>
      _MainMasterProduksiScreenState();
}

class _MainMasterProduksiScreenState extends State<MainMasterProduksiScreen> {
  bool hasNewNotif = false;

  @override
  void initState() {
    super.initState();
    checkNotifications();
  }

  Future<void> checkNotifications() async {
    bool newNotif = await hasNewNotifications('Produksi');
    setState(() {
      hasNewNotif = newNotif;
    });
  }

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
                            if (kIsWeb) {
                              Routemaster.of(context).push(
                                '${NotifikasiScreen.routeName}?routeBack=${MainProduksi.routeName}?selectedIndex=2',
                              );
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
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
                              if (hasNewNotif)
                                Positioned(
                                  bottom: 0,
                                  right: 20,
                                  child: Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CardItem(
                      icon: Icons.warehouse,
                      textA: 'Master Bahan',
                      textB: 'Memodifikasi dan melihat data bahan',
                      pageRoute: '${ListMasterBahanScreen.routeName}?mode=3',
                      pageWidget: ListMasterBahanScreen(),
                    ),
                    const CardItem(
                      icon: Icons.notes_rounded,
                      textA: 'Master Bill of Material',
                      textB: 'Memodifikasi dan melihat data BOM',
                      pageRoute: ListBOMScreen.routeName,
                      pageWidget: ListBOMScreen(),
                    ),
                    const CardItem(
                      icon: Icons.factory_outlined,
                      textA: 'Master Mesin',
                      textB: 'Memodifikasi dan melihat data mesin',
                      pageRoute: '${ListMasterMesinScreen.routeName}?mode=3',
                      pageWidget: ListMasterMesinScreen(),
                    ),
                    const CardItem(
                      icon: Icons.gif_box,
                      textA: 'Master Barang',
                      textB: 'Memodifikasi dan melihat data barang',
                      pageRoute: '${ListMasterBarangScreen.routeName}?mode=3',
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
