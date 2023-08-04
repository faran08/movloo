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
    apiKey: 'AIzaSyAE0M40rx6_eK3d9t39fkdrSNqs75dD33Q',
    appId: '1:466454876497:web:a1f7e86cb915cd0fba8370',
    messagingSenderId: '466454876497',
    projectId: 'moovloo',
    authDomain: 'moovloo.firebaseapp.com',
    storageBucket: 'moovloo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzfS7CgvCA5a-GnEDwOUIDlXyH4bAk7wg',
    appId: '1:466454876497:android:ee70e378b345d286ba8370',
    messagingSenderId: '466454876497',
    projectId: 'moovloo',
    storageBucket: 'moovloo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBG4OiV60ih_9ZAxpuLzLIJVUrmE02o-ps',
    appId: '1:466454876497:ios:c77486dcca06d76dba8370',
    messagingSenderId: '466454876497',
    projectId: 'moovloo',
    storageBucket: 'moovloo.appspot.com',
    iosClientId: '466454876497-71v4t3st2dhokuanhlonif1jjedaet62.apps.googleusercontent.com',
    iosBundleId: 'com.example.movloo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBG4OiV60ih_9ZAxpuLzLIJVUrmE02o-ps',
    appId: '1:466454876497:ios:c77486dcca06d76dba8370',
    messagingSenderId: '466454876497',
    projectId: 'moovloo',
    storageBucket: 'moovloo.appspot.com',
    iosClientId: '466454876497-71v4t3st2dhokuanhlonif1jjedaet62.apps.googleusercontent.com',
    iosBundleId: 'com.example.movloo',
  );
}
