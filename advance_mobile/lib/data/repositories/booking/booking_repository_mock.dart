import '../../../model/bike/bike.dart';
import '../../../model/booking/booking.dart';
import 'booking_repository.dart';
import '../mock_data_store.dart';

class MockBookingRepository implements IBookingRepository {
  MockBookingRepository(this._store);

  final MockDataStore _store;

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _store.simulateNetworkDelay();

    final index = _store.bookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index == -1) {
      throw Exception('Booking not found: $bookingId');
    }

    final booking = _store.bookings[index];
    _store.bookings[index] = booking.copyWith(status: BookingStatus.cancelled);

    final bikeIndex = _store.bikes.indexWhere(
      (bike) => bike.id == booking.bikeId,
    );
    if (bikeIndex != -1) {
      _store.bikes[bikeIndex] = _store.bikes[bikeIndex].copyWith(
        status: BikeStatus.available,
      );
      _store.syncStationAvailability(_store.bikes[bikeIndex].stationId);
    }

    _store.notifyChanged();
  }

  @override
  Future<void> completeBooking(
    String bookingId, {
    required DateTime returnDate,
    required double rideDistance,
    required int rideDuration,
  }) async {
    await _store.simulateNetworkDelay();

    final bookingIndex = _store.bookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (bookingIndex == -1) {
      throw Exception('Booking not found: $bookingId');
    }

    final booking = _store.bookings[bookingIndex];
    _store.bookings[bookingIndex] = booking.copyWith(
      status: BookingStatus.completed,
      returnDate: returnDate,
      rideDistance: rideDistance,
      rideDuration: rideDuration,
    );

    final bikeIndex = _store.bikes.indexWhere(
      (bike) => bike.id == booking.bikeId,
    );
    if (bikeIndex != -1) {
      _store.bikes[bikeIndex] = _store.bikes[bikeIndex].copyWith(
        status: BikeStatus.available,
      );
      _store.syncStationAvailability(booking.stationId);
    }

    _store.notifyChanged();
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    await _store.simulateNetworkDelay();

    final bikeIndex = _store.bikes.indexWhere(
      (bike) => bike.id == booking.bikeId,
    );
    if (bikeIndex == -1) {
      throw Exception('Bike not found: ${booking.bikeId}');
    }

    final bike = _store.bikes[bikeIndex];
    if (bike.status != BikeStatus.available) {
      throw Exception('Bike is not available for booking');
    }

    final activeBooking = await getActiveBookingByUserId(booking.userId);
    if (activeBooking != null) {
      throw Exception('User already has an active booking');
    }

    final createdBooking = booking.copyWith(
      id: booking.id.isEmpty ? _store.nextId('booking') : booking.id,
      bookingDate: booking.bookingDate,
      status: BookingStatus.active,
    );

    _store.bookings.add(createdBooking);
    _store.bikes[bikeIndex] = bike.copyWith(status: BikeStatus.booked);
    _store.syncStationAvailability(booking.stationId);
    _store.notifyChanged();

    return createdBooking;
  }

  @override
  Future<Booking?> getActiveBookingByUserId(String userId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.bookings.firstWhere(
        (booking) =>
            booking.userId == userId && booking.status == BookingStatus.active,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Booking>> getBookingHistory(
    String userId, {
    int limit = 50,
  }) async {
    await _store.simulateNetworkDelay();

    final history = _store.bookings.where((booking) {
      return booking.userId == userId && booking.status != BookingStatus.active;
    }).toList();

    history.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return history.take(limit).toList();
  }

  @override
  Future<List<Booking>> getBookingsByUserId(String userId) async {
    await _store.simulateNetworkDelay();
    final bookings = _store.bookings
        .where((booking) => booking.userId == userId)
        .toList();
    bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return bookings;
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    await _store.simulateNetworkDelay();

    final index = _store.bookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index == -1) {
      throw Exception('Booking not found: $bookingId');
    }

    _store.bookings[index] = _store.bookings[index].copyWith(status: status);
    _store.notifyChanged();
  }

  @override
  Stream<Booking?> watchActiveBooking(String userId) async* {
    yield await getActiveBookingByUserId(userId);
    await for (final _ in _store.changes) {
      yield await getActiveBookingByUserId(userId);
    }
  }

  @override
  Stream<List<Booking>> watchBookingsByUserId(String userId) async* {
    yield await getBookingsByUserId(userId);
    await for (final _ in _store.changes) {
      yield await getBookingsByUserId(userId);
    }
  }
}
