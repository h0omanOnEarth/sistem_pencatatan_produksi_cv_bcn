import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/bottom_navigation_bar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/form_faktur_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/form_pesanan_pengiriman.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/form_pesanan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_delivery_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_faktur_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_pesanan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_supplier_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';

import 'main_pembelian.dart';
import 'main_penjualan.dart';

class MainAdministrasi extends StatefulWidget {
  static const routeName = '/main_admnistrasi';

  const MainAdministrasi({Key? key}) : super(key: key);

  @override
  State<MainAdministrasi> createState() => _MainAdministrasiState();
}

class _MainAdministrasiState extends State<MainAdministrasi> {
  late dynamic menu = const HomeScreenAdministrasi();

  void _onItemTapped(int index) {
    setState(() {
      BottomNavigationAdministrasi.menu = BottomNavigationAdministrasi.getMenuByIndex(index);
      menu = BottomNavigationAdministrasi.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
          title: 'Main Administrasi',
          theme: ThemeData(
            primaryColor: Colors.white, // Replace with your desired color
          ),
          home: Scaffold(
            body: GestureDetector(
              onTap: () => setState(() {
                menu = BottomNavigationAdministrasi.menu;
              }),
              child: menu,
            ),
            bottomNavigationBar: BottomNavigationAdministrasi(
              onItemTapped: _onItemTapped,
            ),
          ),
          routes: {
            //Administrasi
            HomeScreenAdministrasi.routeName:(context)=>const HomeScreenAdministrasi(),
            ProfileScreen.routeName:(context)=>const ProfileScreen(),
            MainAdministrasi.routeName: (context) => const MainAdministrasi(),
            MainMasterAdministrasiScreen.routeName:(context) => const MainMasterAdministrasiScreen(),
            NotifikasiScreen.routeName:(context)=>const NotifikasiScreen(),
            MainPembelianAdministrasiScreen.routeName:(context) => const MainPembelianAdministrasiScreen(),
            MainPenjulanAdministrasiScreen.routeName:(context) => const MainPenjulanAdministrasiScreen(),
            MainLaporanAdministrasiScreen.routeName:(context) => const MainLaporanAdministrasiScreen(),

            //Form Master
            FormMasterPelangganScreen.routeName:(context)=> const FormMasterPelangganScreen(),
            FormMasterSupplierScreen.routeName:(context)=> const FormMasterSupplierScreen(),
            FormMasterPegawaiScreen.routeName:(context)=> const FormMasterPegawaiScreen(),
            FormMasterBahanScreen.routeName: (context)=> const FormMasterBahanScreen(),
            FormMasterMesinScreen.routeName:(context)=> const FormMasterMesinScreen(),
            FormMasterBarangScreen.routeName:(context) =>const FormMasterBarangScreen(),

            //list master
            ListMasterPelangganScreen.routeName:(context) => const ListMasterPelangganScreen(),
            ListMasterMesinScreen.routeName:(context) => const ListMasterMesinScreen(),
            ListMasterSupplierScreen.routeName:(context)=> const ListMasterSupplierScreen(),
            ListMasterPegawaiScreen.routeName:(context)=> const ListMasterPegawaiScreen(),
            ListMasterBarangScreen.routeName:(context)=> const ListMasterBarangScreen(),
            ListMasterBahanScreen.routeName:(context)=> const ListMasterBahanScreen(),

            //Form Pembelian
            FormPesananPembelianScreen.routeName:(context)=> const FormPesananPembelianScreen(),
            FormPengembalianPesananScreen.routeName:(context)=> const FormPengembalianPesananScreen(),
            ListPesananPembelian.routeName:(context)=> const ListPesananPembelian(),
            ListPesananPengembalianPembelian.routeName:(context)=> const ListPesananPengembalianPembelian(),
            
            //Form Penjualan
            FormPesananPelangganScreen.routeName:(context) => const FormPesananPelangganScreen(),
            FormPesananPengirimanScreen.routeName:(context) => const FormPesananPengirimanScreen(),
            FormFakturPenjualanScreen.routeName:(context) => const FormFakturPenjualanScreen(),
            ListPesananPelanggan.routeName:(context) => const ListPesananPelanggan(),
            ListPesananPengiriman.routeName:(context) => const ListPesananPengiriman(),
            ListFakturPenjualan.routeName:(context)=> const ListFakturPenjualan()
            
          });
  }
}
