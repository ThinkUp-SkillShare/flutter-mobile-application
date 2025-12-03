import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAA3X5Be0omfOuCBiq-kFtdm0A5xAdQu8g',
    appId: '1:647786466720:android:9b8dbb6c4c40e6053f28c5',
    messagingSenderId: '647786466720',
    projectId: 'skillshare-flutter-da4ad',
    authDomain: 'skillshare-flutter-da4ad.firebaseapp.com',
    storageBucket: 'skillshare-flutter-da4ad.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAA3X5Be0omfOuCBiq-kFtdm0A5xAdQu8g',
    appId: '1:647786466720:android:9b8dbb6c4c40e6053f28c5',
    messagingSenderId: '647786466720',
    projectId: 'skillshare-flutter-da4ad',
    storageBucket: 'skillshare-flutter-da4ad.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAA3X5Be0omfOuCBiq-kFtdm0A5xAdQu8g',
    appId: '1:647786466720:android:9b8dbb6c4c40e6053f28c5',
    messagingSenderId: '647786466720',
    projectId: 'skillshare-flutter-da4ad',
    storageBucket: 'skillshare-flutter-da4ad.appspot.com',
    iosBundleId: 'com.example.skillshare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAA3X5Be0omfOuCBiq-kFtdm0A5xAdQu8g',
    appId: '1:647786466720:android:9b8dbb6c4c40e6053f28c5',
    messagingSenderId: '647786466720',
    projectId: 'skillshare-flutter-da4ad',
    storageBucket: 'skillshare-flutter-da4ad.appspot.com',
    iosBundleId: 'com.example.skillshare',
  );
}