import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_directlabor_overhead.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_konfirmasi_hasil.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_pengembalian_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_penggunaan_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_permintaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_production_order.dart';

class MainProsesProduksiScreen extends StatefulWidget {
  static const routeName = '/main_proses_produksi';
  const MainProsesProduksiScreen({Key? key});

  @override
  State<MainProsesProduksiScreen> createState() => _MainProsesProduksiScreenState();
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
                    const CardItem(icon: Icons.online_prediction_rounded, textA: 'Perintah Produksi', textB: 'Memodifikasi dan melihat perintah produksi', pageRoute: ListProductionOrder()),
                    const CardItem(icon: Icons.note_add, textA: 'Permintaan Bahan', textB: 'Memodifikasi dan melihat permintaan bahan', pageRoute: FormPermintaanBahanScreen()),
                    const CardItem(icon: Icons.wifi_protected_setup_sharp, textA: 'Penggunaan Bahan', textB: 'Memodifikasi dan melihat pengguaan bahan', pageRoute: FormPenggunaanBahanScreen()),
                    const CardItem(icon: Icons.move_down, textA: 'Pengembalian Bahan', textB: 'Memodifikasi dan melihat pengembalian bahan', pageRoute: FormPengembalianBahanScreen()),
                    const CardItem(icon: Icons.note_alt_rounded, textA: 'Pencatatan Direct Labor & Overhead Cost', textB: 'Memodifikasi dan melihat direct labor & overhead cost', pageRoute: FormPencatatanDirectLaborScreen()),
                    const CardItem(icon: Icons.sticky_note_2, textA: 'Hasil Produksi', textB: 'Memodifikasi dan melihat hasil produksi', pageRoute: FormHasilProduksiScreen()),
                    const CardItem(icon: Icons.check_circle, textA: 'Konfirmasi Produksi', textB: 'Memodifikasi dan melihat Konfirmasi Produksi', pageRoute: FormKonfirmasiProduksiScreen()),
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

class CardItem extends StatelessWidget {
  final IconData icon;
  final String textA;
  final String textB;
  final Widget pageRoute; // New property to specify the page route

  const CardItem({
    required this.icon,
    required this.textA,
    required this.textB,
    required this.pageRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,MaterialPageRoute( builder: (context) => pageRoute,),
      );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Set corner radius
          side: const BorderSide(
            color: Colors.grey, // Set border color
            width: 1.0, // Set border width
          ),
        ),
        child: Container(
          height: 110.0, // Set the desired height of the card
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40.0, // Set the width for the icon
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    icon,
                    size: 36, // Customize the icon size
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textA,
                      style: const TextStyle(
                        fontSize: 18, // Customize the font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    Text(textB),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
