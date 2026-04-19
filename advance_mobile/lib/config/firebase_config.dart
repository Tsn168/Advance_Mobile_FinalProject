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
}
