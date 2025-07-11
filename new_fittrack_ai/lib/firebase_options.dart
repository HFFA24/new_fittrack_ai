// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAz0TI2kfZB2JGtmcv1la8Pd72S1Xmver0',
    appId: '1:1060155110836:web:b1a5bd40545dda4eea6ee1',
    messagingSenderId: '1060155110836',
    projectId: 'fittrackai-4d4f0',
    authDomain: 'fittrackai-4d4f0.firebaseapp.com',
    storageBucket: 'fittrackai-4d4f0.firebasestorage.app',
    measurementId: 'G-DV9KZMQKM8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDN-3pmPleX_C_iDFPkJKGftPJitzt-oKk',
    appId: '1:1060155110836:android:8e0ad2452748396dea6ee1',
    messagingSenderId: '1060155110836',
    projectId: 'fittrackai-4d4f0',
    storageBucket: 'fittrackai-4d4f0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsFzorNPi5zCXrvQeOTMK7s7Hm0BSIenI',
    appId: '1:1060155110836:ios:66f844a9af0b571cea6ee1',
    messagingSenderId: '1060155110836',
    projectId: 'fittrackai-4d4f0',
    storageBucket: 'fittrackai-4d4f0.firebasestorage.app',
    iosClientId: '1060155110836-tuuuee1sb36i7o0ffljrkf81n5cekip1.apps.googleusercontent.com',
    iosBundleId: 'com.example.fittrackAi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAsFzorNPi5zCXrvQeOTMK7s7Hm0BSIenI',
    appId: '1:1060155110836:ios:66f844a9af0b571cea6ee1',
    messagingSenderId: '1060155110836',
    projectId: 'fittrackai-4d4f0',
    storageBucket: 'fittrackai-4d4f0.firebasestorage.app',
    iosClientId: '1060155110836-tuuuee1sb36i7o0ffljrkf81n5cekip1.apps.googleusercontent.com',
    iosBundleId: 'com.example.fittrackAi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAz0TI2kfZB2JGtmcv1la8Pd72S1Xmver0',
    appId: '1:1060155110836:web:da6b1124d9fc3ff0ea6ee1',
    messagingSenderId: '1060155110836',
    projectId: 'fittrackai-4d4f0',
    authDomain: 'fittrackai-4d4f0.firebaseapp.com',
    storageBucket: 'fittrackai-4d4f0.firebasestorage.app',
    measurementId: 'G-375H4PG8QB',
  );
}
