import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/bottom_navigaton.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/form/form_penerimaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/form/form_permintaan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_material_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_purchase_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/form/form_pengembalian_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/form/form_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_customer_order_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/form/form_pemindahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/form/form_penerimaan_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/form/form_pengubahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pemindahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_penerimaan_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pengubahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/sidebar_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_barang.dart';

import 'main_pembelian.dart';


class MainGudang extends StatefulWidget {
  static const routeName = '/main_gudang';

  const MainGudang({Key? key}) : super(key: key);

  @override
  State<MainGudang> createState() => _MainGudangState();
}

class _MainGudangState extends State<MainGudang> {
  late dynamic menu = const HomeScreenGudang();
  int _selectedIndex = 0; // Add this line

  bool _isSidebarCollapsed = false; // Add this line

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationGudang.menu = BottomNavigationGudang.getMenuByIndex(index);
      menu = BottomNavigationGudang.menu;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
          title: 'Main Gudang',
          theme: ThemeData(
            primaryColor: Colors.white, // Replace with your desired color
          ),
          home: ResponsiveBuilder(
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
          ),
          routes: {
            //Gudang
           ProfileScreen.routeName:(context)=> const ProfileScreen(),
           MainMasterGudangScreen.routeName:(context)=> const MainMasterGudangScreen(),
           MainPembelianGudangScreen.routeName:(context)=>const MainPembelianGudangScreen(),
           MainPenjualanGudangScreen.routeName:(context)=>const MainPenjualanGudangScreen(),
           MainProduksiGudangScreen.routeName:(context)=>const MainProduksiGudangScreen(),
           MainLaporanGudangScreen.routeName:(context)=>const MainLaporanGudangScreen(),

           //Form
           FormMasterBahanScreen.routeName: (context)=> const FormMasterBahanScreen(),
           FormMasterBarangScreen.routeName:(context) =>const FormMasterBarangScreen(),
           
           FormPermintaanPembelianScreen.routeName:(context)=> const FormPermintaanPembelianScreen(),
           FormPenerimaanBahanScreen.routeName:(context)=> const FormPenerimaanBahanScreen(),
           FormSuratJalanScreen.routeName:(context)=> const FormSuratJalanScreen(),
           FormPengembalianBarangScreen.routeName:(context)=> const FormPengembalianBarangScreen(),
           FormPengubahanBahan.routeName:(context)=> const FormPengubahanBahan(),
           FormPenerimaanHasilProduksi.routeName:(context)=> const FormPenerimaanHasilProduksi(),
           FormPemindahanBahan.routeName:(context)=> const FormPemindahanBahan(),

           //List
           ListPurchaseRequest.routeName:(context)=> const ListPurchaseRequest(),
           ListMaterialReceive.routeName:(context) => const ListMaterialReceive(),
           ListSuratJalan.routeName:(context)=> const ListSuratJalan(),
           ListCustomerOrderReturn.routeName:(context)=> const ListCustomerOrderReturn(),
           ListPemindahanBahan.routeName:(context)=> const ListPemindahanBahan(),
           ListItemReceive.routeName:(context)=> const ListItemReceive(),
           ListPengubahanBahan.routeName:(context)=> const ListPengubahanBahan()

          });
  }
}
