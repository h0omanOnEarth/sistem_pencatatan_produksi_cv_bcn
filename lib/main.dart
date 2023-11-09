import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/providers/bloc_providers.dart';

import 'package:sistem_manajemen_produksi_cv_bcn/routes/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFunctions.instanceFor(region: "asia-southeast2")
      .useFunctionsEmulator('localhost', 5001); // If you're using the emulator

  configureApp();
  runApp(const MyApp());
  AwesomeNotifications().initialize(
    'assets/images/logo2.jpg',
    [
      NotificationChannel(
          channelGroupKey: 'reminders',
          channelKey: 'instant_notification',
          channelName: 'Basic Instant Notification',
          channelDescription:
              'Notification channel that can trigger notification instantly.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white),
    ],
  );
}

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.providers,
      child: MaterialApp.router(
        routerDelegate: RoutemasterDelegate(routesBuilder: (_) => routes),
        routeInformationParser: const RoutemasterParser(),
      ),
    );
  }
}
