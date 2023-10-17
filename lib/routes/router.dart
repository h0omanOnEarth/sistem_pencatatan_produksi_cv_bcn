import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_delivery_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_faktur_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/list_pesanan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/edit_passowrd_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/edit_profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_material_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_purchase_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_customer_order_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/list/list_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pemindahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_penerimaan_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/list/list_pengubahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/login_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/list/list_supplier_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_proses.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_dloh.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_hasil_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_konfirmasi_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_pengembalian_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_penggunaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_permintaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/list/list_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/splash_screen.dart';

import '/screens/administrasi/main/main_laporan.dart';
import '/screens/gudang/main/main_laporan.dart';
import '/screens/gudang/main/main_penjualan.dart';
import '/screens/gudang/main/main_produksi.dart';

final routes = RouteMap(
  onUnknownRoute: (path) {
    return const MaterialPage(child: SplashScreen()); // Rute default jika rute tidak ditemukan
  },
  routes: {
    SplashScreen.routeName: (_) => const MaterialPage(child: SplashScreen()),
    MainMenuScreen.routeName: (_) => const MaterialPage(child: MainMenuScreen()),
    LoginPageScreen.routeName: (_) => const MaterialPage(child: LoginPageScreen()),
    MainAdministrasi.routeName: (data) {
      final selectedIndex = data?.queryParameters['selectedIndex'];
      final selectedIndexValue = selectedIndex != null ? int.tryParse(selectedIndex) : null;
      // Kemudian gunakan selectedIndexValue sesuai kebutuhan
      return MaterialPage(child: MainAdministrasi(selectedIndex: selectedIndexValue));
    },
    MainMasterAdministrasiScreen.routeName: (_)=> const MaterialPage(child: MainMasterAdministrasiScreen()),
    ListMasterBarangScreen.routeName: (data)=> MaterialPage(child: ListMasterBarangScreen(mode: int.tryParse(data.queryParameters['mode']!))),
    ListMasterBahanScreen.routeName:(data)=> MaterialPage(child: ListMasterBahanScreen(mode: int.tryParse(data.queryParameters['mode']!),)),
    ListMasterMesinScreen.routeName : (data)=>  MaterialPage(child: ListMasterMesinScreen(mode: int.tryParse(data.queryParameters['mode']!),)),
    ListMasterPegawaiScreen.routeName : (_)=>  const MaterialPage(child: ListMasterPegawaiScreen()),
    ListMasterSupplierScreen.routeName: (_)=>  const MaterialPage(child: ListMasterSupplierScreen()),
    ListMasterPelangganScreen.routeName: (_)=>  const MaterialPage(child: ListMasterPelangganScreen()),
    ListPesananPelanggan.routeName : (_)=>  const MaterialPage(child: ListPesananPelanggan()),
    ListPesananPengiriman.routeName: (_)=> const MaterialPage(child: ListPesananPengiriman()),
    ListFakturPenjualan.routeName:(_)=> const MaterialPage(child: ListFakturPenjualan()),
    ListPesananPengembalianPembelian.routeName: (_)=> const MaterialPage(child: ListPesananPengembalianPembelian()),
    ListPesananPembelian.routeName:(_)=> const MaterialPage(child: ListPesananPembelian()),
    ListBOMScreen.routeName:(_)=> const MaterialPage(child: ListBOMScreen()),
    MainProduksi.routeName: (data) {
      final selectedIndex = data?.queryParameters['selectedIndex'];
      final selectedIndexValue = selectedIndex != null ? int.tryParse(selectedIndex) : null;
      // Kemudian gunakan selectedIndexValue sesuai kebutuhan
      return MaterialPage(child: MainProduksi(selectedIndex: selectedIndexValue));
    },
    ListProductionOrder.routeName: (_)=> const MaterialPage(child: ListProductionOrder()),
    ListMaterialRequest.routeName: (_)=> const MaterialPage(child: ListMaterialRequest()),
    ListMaterialUsage.routeName: (_)=> const MaterialPage(child: ListMaterialUsage()),
    ListPengembalianBahan.routeName: (_)=> const MaterialPage(child: ListPengembalianBahan()),
    ListDLOHC.routeName: (_)=> const MaterialPage(child: ListDLOHC()),
    ListHasilProduksi.routeName: (_)=> const MaterialPage(child: ListHasilProduksi()),
    ListKonfirmasiProduksi.routeName: (_)=> const MaterialPage(child: ListKonfirmasiProduksi()),


    MainGudang.routeName: (data) {
      final selectedIndex = data.queryParameters['selectedIndex'];
      final selectedIndexValue = selectedIndex != null ? int.tryParse(selectedIndex) : null;
      // Kemudian gunakan selectedIndexValue sesuai kebutuhan
      return MaterialPage(child: MainGudang(selectedIndex: selectedIndexValue));
    },
    ListPurchaseRequest.routeName: (_)=> const MaterialPage(child: ListPurchaseRequest()),
    ListMaterialReceive.routeName: (_)=> const MaterialPage(child: ListMaterialReceive()),
    ListSuratJalan.routeName: (_)=> const MaterialPage(child: ListSuratJalan()),
    ListCustomerOrderReturn.routeName: (_)=> const MaterialPage(child: ListCustomerOrderReturn()),
    ListItemReceive.routeName: (_)=> const MaterialPage(child: ListItemReceive()),
    ListPemindahanBahan.routeName: (_)=> const MaterialPage(child: ListPemindahanBahan()),
    ListPengubahanBahan.routeName: (_)=> const MaterialPage(child: ListPengubahanBahan()),

    FormMasterSupplierScreen.routeName: (data) {
      final supplierId = data.queryParameters['supplierId'];
      final supplierIdValue = supplierId ??'';
      // Kemudian gunakan selectedIndexValue sesuai kebutuhan
      return MaterialPage(child: FormMasterSupplierScreen(supplierId: supplierId));
    },
  },
);
