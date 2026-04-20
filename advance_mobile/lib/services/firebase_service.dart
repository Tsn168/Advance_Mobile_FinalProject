import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

/// Handles Firebase initialization.
/// Call [FirebaseService.initialize()] once in main.dart before runApp().
class FirebaseService {
  static bool _initialized = false;
  static bool _canUseFirebaseRepositories = false;

  /// Initialize Firebase — must be called before using any Firebase feature
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      _canUseFirebaseRepositories = true;
      return;
    }

    if (kIsWeb) {
      if (!FirebaseConfig.hasWebOptions) {
        debugPrint(
          'Firebase web options are not configured. '
          'Skipping Firebase initialization and running with local/mock services.',
        );
        _initialized = true;
        _canUseFirebaseRepositories = false;
        return;
      }

      await Firebase.initializeApp(options: FirebaseConfig.webOptions);
      _initialized = true;
      _canUseFirebaseRepositories = true;
      return;
    }

    await Firebase.initializeApp(
      options: FirebaseConfig.hasWebOptions ? FirebaseConfig.webOptions : null,
    );
    _initialized = true;
    _canUseFirebaseRepositories = true;
  }

  /// Check if Firebase has been initialized
  static bool get isInitialized => _initialized;

  /// True when repositories should use Firebase backend.
  static bool get canUseFirebaseRepositories => _canUseFirebaseRepositories;
}
