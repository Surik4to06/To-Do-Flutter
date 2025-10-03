// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      // Android / iOS
      return mobile;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDagxM_xqBvlSyMwu-J24wfNEWekIYdBaE",
    authDomain: "tasksapp-aecc7.firebaseapp.com",
    projectId: "tasksapp-aecc7",
    storageBucket: "tasksapp-aecc7.appspot.com",
    messagingSenderId: "109470348957",
    appId: "1:109470348957:web:facf82432f1359dfd9c674",
    measurementId: "G-MVF2QK7NG8",
  );

  static const FirebaseOptions mobile = FirebaseOptions(
    apiKey: "AIzaSyAvyiciYduigk57ZJQmniUcXxmGcpKcpiM",
    appId: "1:109470348957:android:1209697385599237d9c674",
    messagingSenderId: "109470348957",
    projectId: "tasksapp-aecc7",
    storageBucket: "tasksapp-aecc7.appspot.com",
  );
}
