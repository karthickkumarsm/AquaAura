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
    apiKey: 'AIzaSyAaDQM2f2ic_SHpR48pi_drx2MCbK8e1RE',
    appId: '1:316852388071:web:8e641f74c02f9b08976242',
    messagingSenderId: '316852388071',
    projectId: 'water-reminder-app-9582a',
    authDomain: 'water-reminder-app-9582a.firebaseapp.com',
    storageBucket: 'water-reminder-app-9582a.appspot.com',
    measurementId: 'G-SG30B1XSSK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGmBrLx8N0C29mgxEaYmzM2AURDTl3Yi4',
    appId: '1:316852388071:android:9be5ae0858ab4142976242',
    messagingSenderId: '316852388071',
    projectId: 'water-reminder-app-9582a',
    storageBucket: 'water-reminder-app-9582a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC20g-khmsvYOl5S1BEuu5flTy4dVPfT_M',
    appId: '1:316852388071:ios:6d83784323269c1f976242',
    messagingSenderId: '316852388071',
    projectId: 'water-reminder-app-9582a',
    storageBucket: 'water-reminder-app-9582a.appspot.com',
    iosBundleId: 'com.example.waterReminderApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC20g-khmsvYOl5S1BEuu5flTy4dVPfT_M',
    appId: '1:316852388071:ios:6d83784323269c1f976242',
    messagingSenderId: '316852388071',
    projectId: 'water-reminder-app-9582a',
    storageBucket: 'water-reminder-app-9582a.appspot.com',
    iosBundleId: 'com.example.waterReminderApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAaDQM2f2ic_SHpR48pi_drx2MCbK8e1RE',
    appId: '1:316852388071:web:d623dd630e6a4067976242',
    messagingSenderId: '316852388071',
    projectId: 'water-reminder-app-9582a',
    authDomain: 'water-reminder-app-9582a.firebaseapp.com',
    storageBucket: 'water-reminder-app-9582a.appspot.com',
    measurementId: 'G-02SG0G0Z39',
  );
}
