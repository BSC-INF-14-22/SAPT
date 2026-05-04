import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

class FirebaseService {
  /// Initializes Firebase with the current platform options.
  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // Adding a timeout to prevent infinite hang on some devices
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('Firebase initialization timed out');
        return Firebase.app(); // Return existing app if possible
      });
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
}
