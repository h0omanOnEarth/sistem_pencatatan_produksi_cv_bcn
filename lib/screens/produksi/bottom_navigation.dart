import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';

import 'main/main_proses.dart';

class BottomNavigationProduksi extends StatefulWidget {
  final Key? key; // Named 'key' parameter
  final Function(int) onItemTapped;
  static dynamic menu = const HomeScreenProduksi();

  const BottomNavigationProduksi({this.key, required this.onItemTapped})
      : super(key: key);

  @override
  _BottomNavigationProduksiState createState() =>
      _BottomNavigationProduksiState();

  static dynamic getMenuByIndex(int index) {
    if (index == 0) {
      return const HomeScreenProduksi(); // Return HomeScreenGudang widget
    } else if (index == 1) {
      return const MainMasterProduksiScreen();
    } else if (index == 2) {
      return const MainProsesProduksiScreen();
    } else if (index == 3) {
      return const MainLaporanProduksiScreen();
    } else if (index == 4) {
      return const ProfileScreen();
    }
    return const HomeScreenProduksi(); // Default menu
  }
}

class _BottomNavigationProduksiState extends State<BottomNavigationProduksi> {
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
      child: SizedBox(
        height: 56, // Sesuaikan dengan tinggi yang diinginkan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationBarItem(0, Icons.home, 'Home'),
            _buildNavigationBarItem(1, Icons.list, 'Master'),
            _buildNavigationBarItem(2, Icons.factory, 'Produksi'),
            _buildNavigationBarItem(3, Icons.report, 'Laporan'),
            _buildNavigationBarItem(4, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}
