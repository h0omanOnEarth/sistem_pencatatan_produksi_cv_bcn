import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/bottom_navigation.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_directlabor_overhead.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_konfirmasi_hasil.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_pengembalian_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_penggunaan_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_permintaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_mesin.dart';
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
           MainLaporanProduksiScreen.routeName:(context)=> const MainLaporanProduksiScreen(),


          //form
          FormMasterBahanScreen.routeName: (context)=> const FormMasterBahanScreen(),
          FormMasterBarangScreen.routeName:(context) =>const FormMasterBarangScreen(),
          FormMasterMesinScreen.routeName: (context)=> const FormMasterMesinScreen(),
          FormMasterBOMScreen.routeName:(context)=> const FormMasterBOMScreen(),
          FormPenggunaanBahanScreen.routeName:(context)=> const FormPenggunaanBahanScreen(),
          FormPengembalianBahanScreen.routeName:(context)=> const FormPengembalianBahanScreen(),
          FormPencatatanDirectLaborScreen.routeName:(context)=> const FormPencatatanDirectLaborScreen(),
          FormHasilProduksiScreen.routeName:(context)=> const FormHasilProduksiScreen(),
          FormKonfirmasiProduksiScreen.routeName:(context)=> const FormKonfirmasiProduksiScreen(),
          ListBOMScreen.routeName:(context)=> const ListBOMScreen(),
          ListMasterBahanScreen.routeName:(context)=> const ListMasterBahanScreen(),
          ListMasterBarangScreen.routeName:(context)=> const ListMasterBarangScreen(),
          ListMasterMesinScreen.routeName:(context)=> const ListMasterMesinScreen(),
          ListProductionOrder.routeName:(context) => const ListProductionOrder(),
          ListMaterialRequest.routeName:(context) => const ListMaterialRequest()


          });
  }
}
