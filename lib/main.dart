import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/authentication_bloc.dart.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/customers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/materials_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/mesin_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/pesanan_pembelian_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/delivery_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/pesanan_pelanggan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/products_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/dloh_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_usage_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/home_screen_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/edit_profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/login_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/main_menu_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/home_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_laporan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_master.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_proses.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/profil_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/splash_screen.dart';

import '/screens/administrasi/main/main_laporan.dart';
import '/screens/gudang/main/main_laporan.dart';
import '/screens/gudang/main/main_penjualan.dart';
import '/screens/gudang/main/main_produksi.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Daftarkan AuthenticationBloc di sini
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(),
        ),
        BlocProvider<SupplierBloc>(
          create: (BuildContext context) => SupplierBloc(),
        ),
        BlocProvider<EmployeeBloc>(
          create: (BuildContext context) => EmployeeBloc(),
        ),
        BlocProvider<MesinBloc>(
          create: (BuildContext context) => MesinBloc(),
        ),
         BlocProvider<MaterialBloc>(
          create: (BuildContext context) => MaterialBloc(),
        ),
         BlocProvider<ProductBloc>(
          create: (BuildContext context) => ProductBloc(),
        ),
         BlocProvider<CustomerBloc>(
          create: (BuildContext context) => CustomerBloc(),
        ),
         BlocProvider<PurchaseOrderBloc>(
          create: (BuildContext context) => PurchaseOrderBloc(),
        ),
         BlocProvider<PurchaseReturnBloc>(
          create: (BuildContext context) => PurchaseReturnBloc(),
        ),
         BlocProvider<CustomerOrderBloc>(
          create: (BuildContext context) => CustomerOrderBloc(),
        ),
        BlocProvider<DeliveryOrderBloc>(
          create: (BuildContext context) => DeliveryOrderBloc(),
        ),
         BlocProvider<BillOfMaterialBloc>(
          create: (BuildContext context) => BillOfMaterialBloc(),
        ),
         BlocProvider<ProductionOrderBloc>(
          create: (BuildContext context) => ProductionOrderBloc(),
        ),
         BlocProvider<MaterialRequestBloc>(
          create: (BuildContext context) => MaterialRequestBloc(),
        ),
         BlocProvider<MaterialUsageBloc>(
          create: (BuildContext context) => MaterialUsageBloc(),
        ),
        BlocProvider<MaterialReturnBloc>(
          create: (BuildContext context) => MaterialReturnBloc(),
        ),
        BlocProvider<DLOHBloc>(
          create: (BuildContext context) => DLOHBloc(),
        ),
      ],
    child : MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
         SplashScreen.routeName: (context) => const SplashScreen(),
         MainMenuScreen.routeName: (context) => const MainMenuScreen(),
         LoginPageScreen.routeName:(context) => LoginPage(),
         ProfileScreen.routeName:(context)=> const ProfileScreen(),
         NotifikasiScreen.routeName:(context)=>const NotifikasiScreen(),
         EditProfileScreen.routeName:(context)=>  EditProfileScreen(),
         
         //administrasi
         MainAdministrasi.routeName:(context)=>MainAdministrasi(),
         HomeScreenAdministrasi.routeName:(context) =>const HomeScreenAdministrasi(),
         MainMasterAdministrasiScreen.routeName:(context) => const MainMasterAdministrasiScreen(),
         MainPembelianAdministrasiScreen.routeName:(context) => const MainPembelianAdministrasiScreen(),
         MainPenjulanAdministrasiScreen.routeName:(context) => const MainPenjulanAdministrasiScreen(),
         MainLaporanAdministrasiScreen.routeName:(context) => const MainLaporanAdministrasiScreen(),

         //Gudang
         MainGudang.routeName:(context)=> const MainGudang(),
         HomeScreenGudang.routeName:(context)=> const HomeScreenGudang(),
         MainMasterGudangScreen.routeName:(context)=> const MainMasterGudangScreen(),
         MainPembelianGudangScreen.routeName:(context)=>const MainPembelianGudangScreen(),
         MainPenjualanGudangScreen.routeName:(context)=>const MainPenjualanGudangScreen(),
         MainProduksiGudangScreen.routeName:(context)=>const MainProduksiGudangScreen(),
         MainLaporanGudangScreen.routeName:(context)=>const MainLaporanGudangScreen(),

         //produksi
         MainProduksi.routeName:(context)=>const MainProduksi(),
         HomeScreenProduksi.routeName:(context)=> const HomeScreenProduksi(),
         MainMasterProduksiScreen.routeName:(context)=> const MainMasterProduksiScreen(),
         MainProsesProduksiScreen.routeName:(context)=> const MainProsesProduksiScreen(),
         MainLaporanProduksiScreen.routeName:(context)=> const MainLaporanProduksiScreen(),

      },
    )
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
