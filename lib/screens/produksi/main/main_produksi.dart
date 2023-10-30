import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/bottom_navigation.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';

class MainProduksi extends StatefulWidget {
  static const routeName = '/mainproduksi';
  final int? selectedIndex;

  const MainProduksi({Key? key, this.selectedIndex}) : super(key: key);

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
      BottomNavigationProduksi.menu =
          BottomNavigationProduksi.getMenuByIndex(index);
      menu = BottomNavigationProduksi.menu;
      _selectedIndex = index; // Add this line
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Scaffold(
            body: Row(
              children: [
                SidebarProduksiWidget(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                  isSidebarCollapsed: _isSidebarCollapsed, // Add this line
                  onToggleSidebar: _toggleSidebar, // Add this line
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      menu = BottomNavigationProduksi.menu;
                    }),
                    child: menu,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: null,
          );
        } else {
          return Scaffold(
            body: GestureDetector(
              onTap: () => setState(() {
                menu = BottomNavigationProduksi.menu;
              }),
              child: menu,
            ),
            bottomNavigationBar: BottomNavigationProduksi(
              onItemTapped: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
