import 'package:firebase_core/firebase_core.dart';

/// Handles Firebase initialization.
/// Call [FirebaseService.initialize()] once in main.dart before runApp().
class FirebaseService {
  static bool _initialized = false;

  /// Initialize Firebase — must be called before using any Firebase feature
  static Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
    }
  }

  /// Check if Firebase has been initialized
  static bool get isInitialized => _initialized;
}
