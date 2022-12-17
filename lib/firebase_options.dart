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
    apiKey: 'AIzaSyCh8fDb2WmYzS5aCh5UW87iN-iMOHE-h5s',
    appId: '1:959949404332:web:abac5b1a3ccef59a234709',
    messagingSenderId: '959949404332',
    projectId: 'disflyandroid',
    authDomain: 'disflyandroid.firebaseapp.com',
    storageBucket: 'disflyandroid.appspot.com',
    measurementId: 'G-ZB95YLCRER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBs94WWNIFjuj4aD_rhsN2dNwy5_Ed0ofA',
    appId: '1:959949404332:android:fdc7b253ff08ff98234709',
    messagingSenderId: '959949404332',
    projectId: 'disflyandroid',
    storageBucket: 'disflyandroid.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2-BXqYn_v49MoYrrPudymJLRRO2yiJvE',
    appId: '1:959949404332:ios:f190f01a41313305234709',
    messagingSenderId: '959949404332',
    projectId: 'disflyandroid',
    storageBucket: 'disflyandroid.appspot.com',
    iosClientId: '959949404332-d7p8dr61lklahce2i4vet89u2bltl5fn.apps.googleusercontent.com',
    iosBundleId: 'com.kidozh.discuz-flutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2-BXqYn_v49MoYrrPudymJLRRO2yiJvE',
    appId: '1:959949404332:ios:fa7bf33574de0788234709',
    messagingSenderId: '959949404332',
    projectId: 'disflyandroid',
    storageBucket: 'disflyandroid.appspot.com',
    iosClientId: '959949404332-uoo8n2o3nd016nvgb3mcd8digqji5mln.apps.googleusercontent.com',
    iosBundleId: 'com.kidozh.discuzFlutter',
  );
}
