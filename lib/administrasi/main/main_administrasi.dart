import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/administrasi/bottom_navigation_bar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/administrasi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/administrasi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/master/form/form_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/master/form/form_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/master/form/form_supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/profil_screen.dart';

import 'main_pembelian.dart';
import 'main_penjualan.dart';

class MainAdministrasi extends StatefulWidget {
  static const routeName = '/main_admnistrasi';

  const MainAdministrasi({Key? key}) : super(key: key);

  @override
  State<MainAdministrasi> createState() => _MainAdministrasiState();
}

class _MainAdministrasiState extends State<MainAdministrasi> {
  late dynamic menu = HomeScreen();

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationAdministrasi.menu = BottomNavigationAdministrasi.getMenuByIndex(index);
      menu = BottomNavigationAdministrasi.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
          title: 'Main Donater',
          theme: ThemeData(
            primaryColor: Colors.white, // Replace with your desired color
          ),
          home: Scaffold(
            body: GestureDetector(
              onTap: () => setState(() {
                menu = BottomNavigationAdministrasi.menu;
              }),
              child: menu,
            ),
            bottomNavigationBar: BottomNavigationAdministrasi(
              onItemTapped: _onItemTapped,
            ),
          ),
          routes: {
            //Administrasi
            HomeScreen.routeName:(context)=>const HomeScreen(),
            ProfileScreen.routeName:(context)=>const ProfileScreen(),
            MainAdministrasi.routeName: (context) => const MainAdministrasi(),
            MainMasterAdministrasiScreen.routeName:(context) => const MainMasterAdministrasiScreen(),
            NotifikasiScreen.routeName:(context)=>NotifikasiScreen(),
            MainPembelianAdministrasiScreen.routeName:(context) => const MainPembelianAdministrasiScreen(),
            MainPenjulanAdministrasiScreen.routeName:(context) => const MainPenjulanAdministrasiScreen(),
            MainLaporanAdministrasiScreen.routeName:(context) => const MainLaporanAdministrasiScreen(),

            FormMasterPelangganScreen.routeName:(context)=> const FormMasterPelangganScreen(),
            FormMasterSupplierScreen.routeName:(context)=> const FormMasterSupplierScreen(),
            FormMasterPegawaiScreen.routeName:(context)=> const FormMasterPegawaiScreen(),
          });
  }
}
