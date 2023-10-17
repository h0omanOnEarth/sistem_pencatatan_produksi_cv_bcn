import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/bottom_navigaton.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/sidebar_gudang.dart';


class MainGudang extends StatefulWidget {
  static const routeName = '/gudang';
  final int? selectedIndex;

  const MainGudang({Key? key,this.selectedIndex}) : super(key: key);

  @override
   State<MainGudang> createState() => _MainGudangState(selectedIndex ?? 0);
}

class _MainGudangState extends State<MainGudang> {
  late dynamic menu = const HomeScreenGudang();
  int _selectedIndex;

  bool _isSidebarCollapsed = false; // Add this line

  _MainGudangState(this._selectedIndex);

  @override
  void initState() {
    super.initState();
    _onItemTapped(_selectedIndex); // Pindahkan _onItemTapped ke initState
  }

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationGudang.menu = BottomNavigationGudang.getMenuByIndex(index);
      menu = BottomNavigationGudang.menu;
      _selectedIndex = index;
    });
  }

  
  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
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
                      SidebarGudangWidget(
                        selectedIndex: _selectedIndex,
                        onItemTapped: _onItemTapped,
                        isSidebarCollapsed: _isSidebarCollapsed, // Add this line
                        onToggleSidebar: _toggleSidebar, // Add this line
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            menu = BottomNavigationGudang.menu;
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
                      menu = BottomNavigationGudang.menu;
                    }),
                    child: menu,
                  ),
                  bottomNavigationBar: BottomNavigationGudang(
                    onItemTapped: _onItemTapped,
                  ),
                );
              }
            },
          );
  }
}
