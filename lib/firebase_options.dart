// File generated from Firebase project bgasapp (android/google-services.json).
// Run `dart pub global run flutterfire_cli:flutterfire configure` to refresh web app id.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmnnUk5zt-rJydKykUVZwDk4c9LSAQWVI',
    appId: '1:1002124420686:web:bgasapp-portal',
    messagingSenderId: '1002124420686',
    projectId: 'bgasapp',
    authDomain: 'bgasapp.firebaseapp.com',
    storageBucket: 'bgasapp.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmnnUk5zt-rJydKykUVZwDk4c9LSAQWVI',
    appId: '1:1002124420686:android:9d05af794c28b11bf3451f',
    messagingSenderId: '1002124420686',
    projectId: 'bgasapp',
    storageBucket: 'bgasapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmnnUk5zt-rJydKykUVZwDk4c9LSAQWVI',
    appId: '1:1002124420686:ios:placeholder',
    messagingSenderId: '1002124420686',
    projectId: 'bgasapp',
    storageBucket: 'bgasapp.firebasestorage.app',
    iosBundleId: 'com.ref.bgasApp',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmnnUk5zt-rJydKykUVZwDk4c9LSAQWVI',
    appId: '1:1002124420686:web:bgasapp-portal',
    messagingSenderId: '1002124420686',
    projectId: 'bgasapp',
    authDomain: 'bgasapp.firebaseapp.com',
    storageBucket: 'bgasapp.firebasestorage.app',
  );
}
