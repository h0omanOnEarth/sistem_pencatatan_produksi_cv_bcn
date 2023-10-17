import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/bottom_navigation_bar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';


class MainAdministrasi extends StatefulWidget {
  static const routeName = '/admnistrasi';
  final int? selectedIndex;

  const MainAdministrasi({Key? key,this.selectedIndex}) : super(key: key);

  @override
  State<MainAdministrasi> createState() => _MainAdministrasiState(selectedIndex ?? 0);
}

class _MainAdministrasiState extends State<MainAdministrasi> {
  late dynamic menu = const HomeScreenAdministrasi();
  int _selectedIndex;

  bool _isSidebarCollapsed = false; // Add this line

  _MainAdministrasiState(this._selectedIndex);

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
      BottomNavigationAdministrasi.menu = BottomNavigationAdministrasi.getMenuByIndex(index);
      menu = BottomNavigationAdministrasi.menu;
      _selectedIndex = index; // Add this line
    });
  }

  @override
  Widget build(BuildContext context) {
    return   ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
              return Scaffold(
                body: Row(
                  children: [
                    SidebarAdministrasiWidget(
                      selectedIndex: _selectedIndex,
                      onItemTapped: _onItemTapped,
                      isSidebarCollapsed: _isSidebarCollapsed, // Add this line
                      onToggleSidebar: _toggleSidebar, // Add this line
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          menu = BottomNavigationAdministrasi.menu;
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
                    menu = BottomNavigationAdministrasi.menu;
                  }),
                  child: menu,
                ),
                bottomNavigationBar: BottomNavigationAdministrasi(
                  onItemTapped: _onItemTapped,
                ),
              );
            }
          },
        );
  }
}
