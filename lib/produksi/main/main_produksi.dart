import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/produksi/bottom_navigation.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/profil_screen.dart';

import 'main_master.dart';
import 'main_proses.dart';


class MainProduksi extends StatefulWidget {
  static const routeName = '/main_produksi';

  const MainProduksi({Key? key}) : super(key: key);

  @override
  State<MainProduksi> createState() => _MainProduksiState();
}

class _MainProduksiState extends State<MainProduksi> {
  late dynamic menu = HomeScreenProduksi();

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationProduksi.menu = BottomNavigationProduksi.getMenuByIndex(index);
      menu = BottomNavigationProduksi.menu;
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
                menu = BottomNavigationProduksi.menu;
              }),
              child: menu,
            ),
            bottomNavigationBar: BottomNavigationProduksi(
              onItemTapped: _onItemTapped,
            ),
          ),
          routes: {
            //Gudang
           ProfileScreen.routeName:(context)=> const ProfileScreen(),
           HomeScreenProduksi.routeName:(context)=>const HomeScreenProduksi(),
           MainMasterProduksiScreen.routeName:(context)=> const MainMasterProduksiScreen(),
           MainProsesProduksiScreen.routeName:(context)=> const MainProsesProduksiScreen(),
           MainLaporanProduksiScreen.routeName:(context)=> const MainLaporanProduksiScreen()
          });
  }
}
