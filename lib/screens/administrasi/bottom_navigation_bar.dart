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
  static dynamic menu = HomeScreenAdministrasi();

  BottomNavigationAdministrasi({this.key, required this.onItemTapped}) : super(key: key);

  @override
  _BottomNavigationAdministrasiState createState() => _BottomNavigationAdministrasiState();

  static dynamic getMenuByIndex(int index) {
    if (index == 0) {
      return HomeScreenAdministrasi();
    } else if (index == 1) {
      return MainMasterAdministrasiScreen();
    } else if (index == 2) {
      return MainPembelianAdministrasiScreen();
    } else if (index == 3) {
      return MainPenjulanAdministrasiScreen();
    }else if (index ==4){
      return MainLaporanAdministrasiScreen();
    }else if(index ==5){
      return ProfileScreen();
    }
    return HomeScreenAdministrasi(); // Default menu
  }
}

class _BottomNavigationAdministrasiState extends State<BottomNavigationAdministrasi> {
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
            color: _selectedIndex == index ? Color.fromRGBO(59, 51, 51, 1) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Color.fromRGBO(59, 51, 51, 1)  : Colors.grey,
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
            _buildNavigationBarItem(4, Icons.report, 'Laporan'),
            _buildNavigationBarItem(5, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}
