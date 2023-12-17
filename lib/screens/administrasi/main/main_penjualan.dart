import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/helper/notification_helper.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
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
  bool hasNewNotif = false;

  @override
  void initState() {
    super.initState();
    checkNotifications();
  }

  Future<void> checkNotifications() async {
    bool newNotif = await hasNewNotifications('Administrasi');
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
                            if (kIsWeb) {
                              Routemaster.of(context).push(
                                '${NotifikasiScreen.routeName}?routeBack=${MainAdministrasi.routeName}?selectedIndex=3',
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
                      icon: Icons.point_of_sale,
                      textA: 'Pesanan Pelanggan',
                      textB: 'Memodifikasi dan melihat pesanan pelanggan',
                      pageRoute: ListPesananPelanggan.routeName,
                      pageWidget: ListPesananPelanggan(),
                    ),
                    const CardItem(
                      icon: Icons.local_shipping,
                      textA: 'Pesanan Pengiriman',
                      textB: 'Memodifikasi dan melihat data pesanan pengiriman',
                      pageRoute: ListPesananPengiriman.routeName,
                      pageWidget: ListPesananPengiriman(),
                    ),
                    const CardItem(
                      icon: Icons.file_present_rounded,
                      textA: 'Faktur',
                      textB: 'Memodifikasi dan melihat data faktur',
                      pageRoute: ListFakturPenjualan.routeName,
                      pageWidget: ListFakturPenjualan(),
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
