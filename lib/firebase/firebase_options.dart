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
    apiKey: 'AIzaSyBeG6B2s4-1I5V8EXOaL2pc8PlK67sa05U',
    appId: '1:933801595548:web:f4370d669afba6d6799359',
    messagingSenderId: '933801595548',
    projectId: 'aysar-47a16',
    authDomain: 'aysar-47a16.firebaseapp.com',
    storageBucket: 'aysar-47a16.appspot.com',
    measurementId: 'G-Z9CD6L8M4M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGKknNS7B9t1tYwAlyw3-ErtFLn2uQfpU',
    appId: '1:933801595548:android:767207713d241e42799359',
    messagingSenderId: '933801595548',
    projectId: 'aysar-47a16',
    storageBucket: 'aysar-47a16.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsYy25IghEahyRq5i15JIEnzGY5wBvQL8',
    appId: '1:933801595548:ios:6f7d54a314a6bbb3799359',
    messagingSenderId: '933801595548',
    projectId: 'aysar-47a16',
    storageBucket: 'aysar-47a16.appspot.com',
    iosBundleId: 'com.example.aysar2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsYy25IghEahyRq5i15JIEnzGY5wBvQL8',
    appId: '1:933801595548:ios:4e474ebdff1fdf36799359',
    messagingSenderId: '933801595548',
    projectId: 'aysar-47a16',
    storageBucket: 'aysar-47a16.appspot.com',
    iosBundleId: 'com.example.aysar2.RunnerTests',
  );
}
