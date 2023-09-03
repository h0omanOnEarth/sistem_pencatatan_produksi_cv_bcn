// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIA6ZIH8j7ofYItl1iP9qNjO3_4O9cWcY',
    appId: '1:514128904326:web:5d32daeb712d9b2b585107',
    messagingSenderId: '514128904326',
    projectId: 'pencatatanproduksibcn',
    authDomain: 'pencatatanproduksibcn.firebaseapp.com',
    storageBucket: 'pencatatanproduksibcn.appspot.com',
    measurementId: 'G-CQCTD3DD9W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRZ6iG8OQO3TAYEoyYOvYfgZJ0M_ZOxwg',
    appId: '1:514128904326:android:c360a5404963dca0585107',
    messagingSenderId: '514128904326',
    projectId: 'pencatatanproduksibcn',
    storageBucket: 'pencatatanproduksibcn.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCAOKyU2HptRdpRbE5GqpGcHN_fuXmgeBc',
    appId: '1:514128904326:ios:380d3ede9aacd6b6585107',
    messagingSenderId: '514128904326',
    projectId: 'pencatatanproduksibcn',
    storageBucket: 'pencatatanproduksibcn.appspot.com',
    iosClientId: '514128904326-ru3gtr7grrne08orumlhuho5jlu5f51u.apps.googleusercontent.com',
    iosBundleId: 'com.example.sistemManajemenProduksiCvBcn',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCAOKyU2HptRdpRbE5GqpGcHN_fuXmgeBc',
    appId: '1:514128904326:ios:bfb3f9aff0a71a1b585107',
    messagingSenderId: '514128904326',
    projectId: 'pencatatanproduksibcn',
    storageBucket: 'pencatatanproduksibcn.appspot.com',
    iosClientId: '514128904326-ur7u69i542au4o62k2fnhk0a38drdmn4.apps.googleusercontent.com',
    iosBundleId: 'com.example.sistemManajemenProduksiCvBcn.RunnerTests',
  );
}
