import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/providers/bloc_providers.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/routes/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseFunctions.instanceFor(region: "asia-southeast2")
  //     .useFunctionsEmulator('localhost', 5001); // If you're using the emulator

  configureApp();
  runApp(const MyApp());
}

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Jika aplikasi dijalankan di web, gunakan Routemaster
      return MultiBlocProvider(
        providers: AppBlocProviders.providers,
        child: MaterialApp.router(
          routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes),
          routeInformationParser: const RoutemasterParser(),
        ),
      );
    } else {
      // Jika aplikasi dijalankan di ponsel atau platform lainnya
      // Gunakan MaterialApp biasa atau Navigator-based routing
      return MultiBlocProvider(
        providers: AppBlocProviders.providers,
        child: const MaterialApp(
          home: SplashScreen(), // Ganti dengan halaman utama yang sesuai
        ),
      );
    }
  }
}
