import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';

class BottomNavigationGudang extends StatefulWidget {
  final Key? key; // Named 'key' parameter
  final Function(int) onItemTapped;
  static dynamic menu = const HomeScreenGudang();

  BottomNavigationGudang({this.key, required this.onItemTapped})
      : super(key: key);

  @override
  _BottomNavigationGudangState createState() => _BottomNavigationGudangState();

  static dynamic getMenuByIndex(int index) {
    if (index == 0) {
      return const HomeScreenGudang(); // Return HomeScreenGudang widget
    } else if (index == 1) {
      return const MainMasterGudangScreen(); // Return MainMasterGudangScreen widget
    } else if (index == 2) {
      return const MainPembelianGudangScreen();
    } else if (index == 3) {
      return const MainPenjualanGudangScreen();
    } else if (index == 4) {
      return const MainProduksiGudangScreen();
    } else if (index == 5) {
      return const MainLaporanGudangScreen();
    } else if (index == 6) {
      return const ProfileScreen(); // Return ProfileScreen widget
    }
    return const HomeScreenGudang(); // Default menu
  }
}

class _BottomNavigationGudangState extends State<BottomNavigationGudang> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onItemTapped(index);
    });
  }

  Widget _buildNavigationBarItem(int index, IconData iconData, String label) {
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
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? const Color.fromRGBO(59, 51, 51, 1)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 56, // Sesuaikan dengan tinggi yang diinginkan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationBarItem(0, Icons.home, 'Home'),
            _buildNavigationBarItem(1, Icons.list, 'Master'),
            _buildNavigationBarItem(2, Icons.shopping_cart, 'Pembelian'),
            _buildNavigationBarItem(3, Icons.shop, 'Penjualan'),
            _buildNavigationBarItem(4, Icons.factory, 'Produksi'),
            _buildNavigationBarItem(5, Icons.report, 'Laporan'),
            _buildNavigationBarItem(6, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}
