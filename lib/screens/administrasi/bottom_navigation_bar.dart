import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';

class BottomNavigationAdministrasi extends StatefulWidget {
  final Key? key; // Named 'key' parameter
  final Function(int) onItemTapped;
  final int selectedIndex;
  static dynamic menu = const HomeScreenAdministrasi();

  const BottomNavigationAdministrasi({
    this.key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _BottomNavigationAdministrasiState createState() =>
      _BottomNavigationAdministrasiState();

  static dynamic getMenuByIndex(int index) {
    if (index == 0) {
      return const HomeScreenAdministrasi();
    } else if (index == 1) {
      return const MainMasterAdministrasiScreen();
    } else if (index == 2) {
      return const MainPembelianAdministrasiScreen();
    } else if (index == 3) {
      return const MainPenjulanAdministrasiScreen();
    } else if (index == 4) {
      return const MainLaporanAdministrasiScreen();
    } else if (index == 5) {
      return const ProfileScreen();
    }
    return const HomeScreenAdministrasi(); // Default menu
  }
}

class _BottomNavigationAdministrasiState
    extends State<BottomNavigationAdministrasi> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onItemTapped(index);
    });
  }

  Widget _buildNavigationBarItem(int index, IconData iconData) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: _selectedIndex == index
                ? const Color.fromRGBO(59, 51, 51, 1)
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 56, // Sesuaikan dengan tinggi yang diinginkan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationBarItem(0, Icons.home),
            _buildNavigationBarItem(1, Icons.list),
            _buildNavigationBarItem(2, Icons.shopping_cart),
            _buildNavigationBarItem(3, Icons.shop),
            _buildNavigationBarItem(4, Icons.report),
            _buildNavigationBarItem(5, Icons.person),
          ],
        ),
      ),
    );
  }
}
