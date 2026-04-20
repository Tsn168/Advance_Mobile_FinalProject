import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

/// Handles Firebase initialization.
/// Call [FirebaseService.initialize()] once in main.dart before runApp().
class FirebaseService {
  static bool _initialized = false;

  /// Initialize Firebase — must be called before using any Firebase feature
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      return;
    }

    if (kIsWeb) {
      if (!FirebaseConfig.hasWebOptions) {
        debugPrint(
          'Firebase web options are not configured. '
          'Skipping Firebase initialization and running with local/mock services.',
        );
        _initialized = true;
        return;
      }

      await Firebase.initializeApp(options: FirebaseConfig.webOptions);
      _initialized = true;
      return;
    }

    await Firebase.initializeApp();
    _initialized = true;
  }

  /// Check if Firebase has been initialized
  static bool get isInitialized => _initialized;
}
