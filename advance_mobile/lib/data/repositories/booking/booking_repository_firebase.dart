import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../config/firebase_config.dart';
import '../../../model/bike/bike.dart';
import '../../../model/booking/booking.dart';
import '../../dtos/booking_dto.dart';
import 'booking_repository.dart';

class BookingRepositoryFirebase implements IBookingRepository {
  BookingRepositoryFirebase({FirebaseDatabase? database})
    : _database =
          database ?? FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: FirebaseConfig.realtimeDatabaseUrl);

  final FirebaseDatabase _database;

  DatabaseReference get _bookingsRef =>
      _database.ref(FirebaseConfig.bookingsPath);
  DatabaseReference get _bikesRef => _database.ref(FirebaseConfig.bikesPath);
  DatabaseReference get _stationsRef =>
      _database.ref(FirebaseConfig.stationsPath);

  @override
  Future<void> cancelBooking(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw Exception('Booking not found: $bookingId');
    }

    await _bookingsRef.child(bookingId).update({
      'status': BookingStatus.cancelled.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);

    await _bikesRef.child(booking.bikeId).update({
      'status': BikeStatus.available.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);

    await _syncStationAvailability(booking.stationId);
  }

  @override
  Future<void> completeBooking(
    String bookingId, {
    required DateTime returnDate,
    required double rideDistance,
    required int rideDuration,
  }) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw Exception('Booking not found: $bookingId');
    }

    await _bookingsRef.child(bookingId).update({
      'status': BookingStatus.completed.name.toUpperCase(),
      'returnDate': returnDate.toUtc().toIso8601String(),
      'rideDistance': rideDistance,
      'rideDuration': rideDuration,
    }).timeout(FirebaseConfig.defaultTimeout);

    await _bikesRef.child(booking.bikeId).update({
      'status': BikeStatus.available.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);

    await _syncStationAvailability(booking.stationId);
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    final bikeSnapshot = await _bikesRef
        .child(booking.bikeId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!bikeSnapshot.exists || bikeSnapshot.value == null) {
      throw Exception('Bike not found: ${booking.bikeId}');
    }

    final bikeMap = Map<String, dynamic>.from(bikeSnapshot.value as Map);
    final bikeStatus = (bikeMap['status'] as String?) ?? 'AVAILABLE';
    if (bikeStatus != BikeStatus.available.name.toUpperCase()) {
      throw Exception('Bike is not available for booking');
    }

    final activeBooking = await getActiveBookingByUserId(booking.userId);
    if (activeBooking != null && activeBooking.id != booking.id) {
      throw Exception('User already has an active booking');
    }

    final bookingId = booking.id.isEmpty ? _bookingsRef.push().key : booking.id;
    if (bookingId == null || bookingId.isEmpty) {
      throw Exception('Unable to generate booking ID');
    }

    final created = booking.copyWith(
      id: bookingId,
      bookingDate: booking.bookingDate.toUtc(),
      status: BookingStatus.active,
    );

    await _bookingsRef
        .child(bookingId)
        .set(BookingDTO.fromModel(created).toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);

    await _bikesRef.child(booking.bikeId).update({
      'status': BikeStatus.booked.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);

    await _syncStationAvailability(booking.stationId);

    return created;
  }

  @override
  Future<Booking?> getActiveBookingByUserId(String userId) async {
    final bookings = await getBookingsByUserId(userId);
    try {
      return bookings.firstWhere((booking) => booking.status == BookingStatus.active);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    final event = await _bookingsRef
        .child(bookingId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(event.value as Map);
    map.putIfAbsent('id', () => bookingId);
    return BookingDTO.fromFirebase(map).toModel();
  }

  @override
  Future<List<Booking>> getBookingHistory(String userId, {int limit = 50}) async {
    final all = await getBookingsByUserId(userId);
    final history = all.where((booking) => booking.status != BookingStatus.active).toList();
    history.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return history.take(limit).toList(growable: false);
  }

  @override
  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final event = await _bookingsRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return <Booking>[];
    }

    final root = Map<String, dynamic>.from(event.value as Map);
    final bookings = <Booking>[];
    root.forEach((key, raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      map.putIfAbsent('id', () => key);
      final booking = BookingDTO.fromFirebase(map).toModel();
      if (booking.userId == userId) {
        bookings.add(booking);
      }
    });

    bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    return bookings;
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _bookingsRef.child(bookingId).update({
      'status': status.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Stream<Booking?> watchActiveBooking(String userId) {
    return _bookingsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return null;
      }

      final root = Map<String, dynamic>.from(value as Map);
      final bookings = <Booking>[];
      root.forEach((key, raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.putIfAbsent('id', () => key);
        final booking = BookingDTO.fromFirebase(map).toModel();
        if (booking.userId == userId && booking.status == BookingStatus.active) {
          bookings.add(booking);
        }
      });

      if (bookings.isEmpty) {
        return null;
      }
      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      return bookings.first;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchActiveBooking($userId) error: $error');
    });
  }

  @override
  Stream<List<Booking>> watchBookingsByUserId(String userId) {
    return _bookingsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return <Booking>[];
      }

      final root = Map<String, dynamic>.from(value as Map);
      final bookings = <Booking>[];
      root.forEach((key, raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.putIfAbsent('id', () => key);
        final booking = BookingDTO.fromFirebase(map).toModel();
        if (booking.userId == userId) {
          bookings.add(booking);
        }
      });

      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      return bookings;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchBookingsByUserId($userId) error: $error');
    });
  }

  Future<void> _syncStationAvailability(String stationId) async {
    final bikesEvent = await _bikesRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!bikesEvent.exists || bikesEvent.value == null) {
      await _stationsRef.child(stationId).update({
        'availableBikes': 0,
        'lastUpdated': DateTime.now().toUtc().toIso8601String(),
      }).timeout(FirebaseConfig.defaultTimeout);
      return;
    }

    final root = Map<String, dynamic>.from(bikesEvent.value as Map);
    var availableCount = 0;
    root.forEach((_, raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      final bikeStationId = map['stationId'] as String?;
      final status = map['status'] as String?;
      if (bikeStationId == stationId && status == BikeStatus.available.name.toUpperCase()) {
        availableCount += 1;
      }
    });

    await _stationsRef.child(stationId).update({
      'availableBikes': availableCount,
      'lastUpdated': DateTime.now().toUtc().toIso8601String(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }
}
