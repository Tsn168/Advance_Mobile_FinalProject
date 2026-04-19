/// Converts ugly Firebase/technical errors into friendly messages for users.
/// Use [ErrorHandlerService.handleError(e)] inside every catch block.
class ErrorHandlerService {
  /// Pass any error/exception here, get back a user-friendly string
  static String handleError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('socket')) {
      return 'No internet connection. Please check your network.';
    }
    if (message.contains('permission-denied') ||
        message.contains('permission') ||
        message.contains('denied')) {
      return 'You don\'t have permission to do this.';
    }
    if (message.contains('not-found') || message.contains('not found')) {
      return 'The requested item was not found.';
    }
    if (message.contains('already-exists')) {
      return 'This item already exists.';
    }
    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (message.contains('unauthenticated') ||
        message.contains('unauthorized')) {
      return 'Please log in to continue.';
    }
    if (message.contains('cancelled')) {
      return 'The operation was cancelled.';
    }
    if (message.contains('unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }
}
