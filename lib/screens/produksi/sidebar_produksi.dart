import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_proses.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/positionWidget.dart';

class SidebarProduksiWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isSidebarCollapsed;
  final Function() onToggleSidebar;
  static dynamic menu = const HomeScreenProduksi();

  const SidebarProduksiWidget({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  static dynamic getMenuByIndex(int index) {
    if (index == 0) {
      return const HomeScreenProduksi();
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

  @override
  State<SidebarProduksiWidget> createState() => _SidebarProduksiWidgetState();
}

class _SidebarProduksiWidgetState extends State<SidebarProduksiWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(widget.isSidebarCollapsed ? Icons.menu : Icons.close),
          onPressed: widget.onToggleSidebar,
        ),
        if (!widget.isSidebarCollapsed)
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'CV. Berlian Cangkir Nusantara',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                PositionWidget(),
                _buildSidebarItem(0, Icons.home, 'Home',
                    iconSize: 24, isActive: widget.selectedIndex == 0),
                _buildSidebarItem(1, Icons.list, 'Master',
                    iconSize: 24, isActive: widget.selectedIndex == 1),
                _buildSidebarItem(2, Icons.factory, 'Produksi',
                    iconSize: 24, isActive: widget.selectedIndex == 2),
                _buildSidebarItem(3, Icons.report, 'Laporan',
                    iconSize: 24, isActive: widget.selectedIndex == 3),
                _buildSidebarItem(4, Icons.person, 'Profile',
                    iconSize: 24, isActive: widget.selectedIndex == 4),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData iconData, String label,
      {double iconSize = 24, required bool isActive}) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Container(
        color: isActive ? const Color.fromRGBO(59, 51, 51, 1) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              iconData,
              color: isActive ? Colors.white : Colors.grey,
              size: iconSize,
            ),
            const SizedBox(width: 16.0),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
