/// App State Enum for managing loading states
enum AppState { idle, loading, success, error }

class AppConstants {
  static const Duration mockNetworkDelay = Duration(milliseconds: 250);
  static const String defaultUserId = 'user_reyu';
}

/// Error Handler Service
class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static bool isNetworkError(dynamic error) {
    return error.toString().contains('Network') ||
        error.toString().contains('socket') ||
        error.toString().contains('Connection');
  }

  static bool isTimeoutError(dynamic error) {
    return error.toString().contains('timeout') ||
        error.toString().contains('TimeoutException');
  }

  static bool isAuthError(dynamic error) {
    return error.toString().contains('Auth') ||
        error.toString().contains('Permission') ||
        error.toString().contains('Unauthorized');
  }
}
