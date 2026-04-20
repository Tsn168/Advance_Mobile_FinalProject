import 'package:firebase_core/firebase_core.dart';

/// Firebase collection names and configuration constants.
/// Use these constants everywhere instead of hardcoding strings like 'users'.
class FirebaseConfig {
  // Collection names in Firestore
  static const String usersCollection = 'users';
  static const String passesCollection = 'passes';
  static const String stationsCollection = 'stations';
  static const String bikesCollection = 'bikes';
  static const String bookingsCollection = 'bookings';

  // Request timeout
  static const Duration defaultTimeout = Duration(seconds: 10);

  // How long to keep cached data before refreshing
  static const Duration cacheDuration = Duration(minutes: 30);

  // Web Firebase configuration (provided via --dart-define)
  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const String webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String webMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
  );
  static const String webProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
  );
  static const String webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const String webStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
  );
  static const String webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );

  static bool get hasWebOptions {
    return webApiKey.isNotEmpty &&
        webAppId.isNotEmpty &&
        webMessagingSenderId.isNotEmpty &&
        webProjectId.isNotEmpty;
  }

  static FirebaseOptions get webOptions {
    return const FirebaseOptions(
      apiKey: webApiKey,
      appId: webAppId,
      messagingSenderId: webMessagingSenderId,
      projectId: webProjectId,
      authDomain: webAuthDomain,
      storageBucket: webStorageBucket,
      measurementId: webMeasurementId,
    );
  }
}
