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
    apiKey: 'AIzaSyASKLFHabT0fjQFdHuwayJ3cV6STZKQzA0',
    appId: '1:426667634294:web:4bc9721b4a9948002af957',
    messagingSenderId: '426667634294',
    projectId: 'childrendaily-d8677',
    authDomain: 'childrendaily-d8677.firebaseapp.com',
    storageBucket: 'childrendaily-d8677.firebasestorage.app',
    measurementId: 'G-EBFK7SL1H6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgkkPI5N7kxtbRaOyfU3u6_dpv-NahZHo',
    appId: '1:426667634294:android:42b9ac9caefcda432af957',
    messagingSenderId: '426667634294',
    projectId: 'childrendaily-d8677',
    storageBucket: 'childrendaily-d8677.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmaQH-O9kqUBQmhjMcdVoq-tTcvzhlTqY',
    appId: '1:426667634294:ios:8602e5fba1c3e6c32af957',
    messagingSenderId: '426667634294',
    projectId: 'childrendaily-d8677',
    storageBucket: 'childrendaily-d8677.firebasestorage.app',
    iosBundleId: 'com.example.children',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCmaQH-O9kqUBQmhjMcdVoq-tTcvzhlTqY',
    appId: '1:426667634294:ios:8602e5fba1c3e6c32af957',
    messagingSenderId: '426667634294',
    projectId: 'childrendaily-d8677',
    storageBucket: 'childrendaily-d8677.firebasestorage.app',
    iosBundleId: 'com.example.children',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyASKLFHabT0fjQFdHuwayJ3cV6STZKQzA0',
    appId: '1:426667634294:web:5bb9f7fdad41ffde2af957',
    messagingSenderId: '426667634294',
    projectId: 'childrendaily-d8677',
    authDomain: 'childrendaily-d8677.firebaseapp.com',
    storageBucket: 'childrendaily-d8677.firebasestorage.app',
    measurementId: 'G-RE0MJJ7BJF',
  );
}
