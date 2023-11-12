import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_dloh.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_konfirmasi_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_pengembalian_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_penggunaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_permintaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainProsesProduksiScreen extends StatefulWidget {
  static const routeName = '/proses';
  const MainProsesProduksiScreen({Key? key});

  @override
  State<MainProsesProduksiScreen> createState() =>
      _MainProsesProduksiScreenState();
}

class _MainProsesProduksiScreenState extends State<MainProsesProduksiScreen> {
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
                            if (kIsWeb) {
                              Routemaster.of(context).push(
                                  '${NotifikasiScreen.routeName}?routeBack=${MainProduksi.routeName}?selectedIndex=2');
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
                      icon: Icons.online_prediction_rounded,
                      textA: 'Perintah Produksi',
                      textB: 'Memodifikasi dan melihat perintah produksi',
                      pageRoute: ListProductionOrder.routeName,
                      pageWidget: ListProductionOrder(),
                    ),
                    const CardItem(
                      icon: Icons.note_add,
                      textA: 'Permintaan Bahan',
                      textB: 'Memodifikasi dan melihat permintaan bahan',
                      pageRoute: ListMaterialRequest.routeName,
                      pageWidget: ListMaterialRequest(),
                    ),
                    const CardItem(
                      icon: Icons.wifi_protected_setup_sharp,
                      textA: 'Penggunaan Bahan',
                      textB: 'Memodifikasi dan melihat pengguaan bahan',
                      pageRoute: ListMaterialUsage.routeName,
                      pageWidget: ListMaterialUsage(),
                    ),
                    const CardItem(
                      icon: Icons.move_down,
                      textA: 'Pengembalian Bahan',
                      textB: 'Memodifikasi dan melihat pengembalian bahan',
                      pageRoute: ListPengembalianBahan.routeName,
                      pageWidget: ListPengembalianBahan(),
                    ),
                    const CardItem(
                      icon: Icons.note_alt_rounded,
                      textA: 'Pencatatan Direct Labor & Overhead Cost',
                      textB:
                          'Memodifikasi dan melihat direct labor & overhead cost',
                      pageRoute: ListDLOHC.routeName,
                      pageWidget: ListDLOHC(),
                    ),
                    const CardItem(
                      icon: Icons.sticky_note_2,
                      textA: 'Hasil Produksi',
                      textB: 'Memodifikasi dan melihat hasil produksi',
                      pageRoute: ListHasilProduksi.routeName,
                      pageWidget: ListHasilProduksi(),
                    ),
                    const CardItem(
                      icon: Icons.check_circle,
                      textA: 'Konfirmasi Produksi',
                      textB: 'Memodifikasi dan melihat Konfirmasi Produksi',
                      pageRoute: ListKonfirmasiProduksi.routeName,
                      pageWidget: ListKonfirmasiProduksi(),
                    ),
                    const SizedBox(height: 16),
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
