import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/helper/notification_helper.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_penerimaan_pengeluaran.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_retur.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_stok_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_stok_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainLaporanGudangScreen extends StatefulWidget {
  static const routeName = '/gudang/laporan';
  const MainLaporanGudangScreen({Key? key});

  @override
  State<MainLaporanGudangScreen> createState() =>
      _MainMasterGudangScreenState();
}

class _MainMasterGudangScreenState extends State<MainLaporanGudangScreen> {
  bool hasNewNotif = false;

  @override
  void initState() {
    super.initState();
    checkNotifications();
  }

  Future<void> checkNotifications() async {
    bool newNotif = await hasNewNotifications('Gudang');
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
                                '${NotifikasiScreen.routeName}?routeBack=${MainGudang.routeName}?selectedIndex=5',
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
                      textA: 'Stok Bahan',
                      textB: 'Melihat laporan stok bahan',
                      pageRoute: LaporanBahanGudang.routeName,
                      pageWidget: LaporanBahanGudang(),
                    ),
                    const CardItem(
                      icon: Icons.edit_note_outlined,
                      textA: 'Stok Barang',
                      textB: 'Melihat laporan stok barang',
                      pageRoute: LaporanBarangGudang.routeName,
                      pageWidget: LaporanBarangGudang(),
                    ),
                    const CardItem(
                      icon: Icons.drive_file_move_rtl,
                      textA: 'Pengiriman dan Penerimaan',
                      textB: 'Melihat laporan pengiriman dan penerimaan',
                      pageRoute: LaporanPenerimaanPengiriman.routeName,
                      pageWidget: LaporanPenerimaanPengiriman(),
                    ),
                    const CardItem(
                      icon: Icons.shopping_cart_checkout,
                      textA: 'Retur Barang',
                      textB: 'Melihat laporan retur barang',
                      pageRoute: LaporanReturBarangGudang.routeName,
                      pageWidget: LaporanReturBarangGudang(),
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
