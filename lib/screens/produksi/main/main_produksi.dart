import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/routes/router.dart';
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
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_dloh.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_konfirmasi_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_pengembalian_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_penggunaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_permintaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_mesin.dart';
import 'main_master.dart';
import 'main_proses.dart';


class MainProduksi extends StatefulWidget {
  static const routeName = '/main_produksi';
  final int? selectedIndex;

  const MainProduksi({Key? key,this.selectedIndex}) : super(key: key);

  @override
  State<MainProduksi> createState() => _MainProduksiState(selectedIndex ?? 0);
}

class _MainProduksiState extends State<MainProduksi> {
  late dynamic menu = const HomeScreenProduksi();
  int _selectedIndex;

  bool _isSidebarCollapsed = false; // Add this line

  _MainProduksiState(this._selectedIndex);

  @override
  void initState() {
    super.initState();
    _onItemTapped(_selectedIndex); // Pindahkan _onItemTapped ke initState
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationProduksi.menu = BottomNavigationProduksi.getMenuByIndex(index);
      menu = BottomNavigationProduksi.menu;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
    MaterialApp.router(
      routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes),
      routeInformationParser: const RoutemasterParser(),
      title: 'Pencatatan CV. Berlian Cangkir Nusantara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
