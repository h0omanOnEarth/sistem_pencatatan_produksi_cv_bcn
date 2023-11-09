import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_penerimaan_pengeluaran.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_retur.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_stok_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/laporan/laporan_stok_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';

class MainLaporanGudangScreen extends StatefulWidget {
  static const routeName = '/gudang/laporan';
  const MainLaporanGudangScreen({Key? key});

  @override
  State<MainLaporanGudangScreen> createState() =>
      _MainMasterGudangScreenState();
}

class _MainMasterGudangScreenState extends State<MainLaporanGudangScreen> {
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
                        icon: Icons.warehouse,
                        textA: 'Stok Bahan',
                        textB: 'Melihat laporan stok bahan',
                        pageRoute: LaporanBahanGudang.routeName),
                    const CardItem(
                        icon: Icons.edit_note_outlined,
                        textA: 'Stok Barang',
                        textB: 'Melihat laporan stok barang',
                        pageRoute: LaporanBarangGudang.routeName),
                    const CardItem(
                        icon: Icons.drive_file_move_rtl,
                        textA: 'Pengiriman dan Penerimaan',
                        textB: 'Melihat laporan pengiriman dan penerimaan',
                        pageRoute: LaporanPenerimaanPengiriman.routeName),
                    const CardItem(
                        icon: Icons.shopping_cart_checkout,
                        textA: 'Retur Barang',
                        textB: 'Melihat laporan retur barang',
                        pageRoute: LaporanReturBarangGudang.routeName),
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
