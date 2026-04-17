import '../../models/booking.dart';

/// Abstract Booking Repository Interface
abstract class IBookingRepository {
  /// Create a new booking
  Future<Booking> createBooking(Booking booking);

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId);

  /// Get all bookings for a user
  Future<List<Booking>> getBookingsByUserId(String userId);

  /// Get active booking for a user
  Future<Booking?> getActiveBookingByUserId(String userId);

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);

  /// Update booking with return info
  Future<void> completeBooking(
    String bookingId, {
    required DateTime returnDate,
    required double rideDistance,
    required int rideDuration,
  });

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId);

  /// Stream of active booking for a user
  Stream<Booking?> watchActiveBooking(String userId);

  /// Stream of all bookings for a user
  Stream<List<Booking>> watchBookingsByUserId(String userId);

  /// Get booking history for a user
  Future<List<Booking>> getBookingHistory(String userId, {int limit = 50});
}
