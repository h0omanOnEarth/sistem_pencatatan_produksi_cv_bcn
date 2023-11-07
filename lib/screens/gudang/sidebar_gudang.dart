import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/positionWidget.dart';

class SidebarGudangWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isSidebarCollapsed;
  final Function() onToggleSidebar;

  const SidebarGudangWidget({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isSidebarCollapsed,
    required this.onToggleSidebar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isSidebarCollapsed ? Icons.menu : Icons.close),
          onPressed: onToggleSidebar,
        ),
        if (!isSidebarCollapsed)
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
                    iconSize: 24, isActive: selectedIndex == 0),
                _buildSidebarItem(1, Icons.list, 'Master',
                    iconSize: 24, isActive: selectedIndex == 1),
                _buildSidebarItem(2, Icons.shopping_cart, 'Pembelian',
                    iconSize: 24, isActive: selectedIndex == 2),
                _buildSidebarItem(3, Icons.shop, 'Penjualan',
                    iconSize: 24, isActive: selectedIndex == 3),
                _buildSidebarItem(4, Icons.factory, 'Produksi',
                    iconSize: 24, isActive: selectedIndex == 4),
                _buildSidebarItem(5, Icons.report, 'Laporan',
                    iconSize: 24, isActive: selectedIndex == 5),
                _buildSidebarItem(6, Icons.person, 'Profile',
                    iconSize: 24, isActive: selectedIndex == 6),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData iconData, String label,
      {double iconSize = 24, required bool isActive}) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
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
