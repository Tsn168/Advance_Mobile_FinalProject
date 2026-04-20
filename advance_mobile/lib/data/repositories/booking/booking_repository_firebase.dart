import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/booking/booking.dart';
import '../../dtos/booking_dto.dart';
import 'booking_repository.dart';
import '../../../config/firebase_config.dart';

/// Real Firebase implementation of the Booking Repository.
/// Uses Firestore Transactions for atomic booking operations.
class BookingRepositoryFirebase implements IBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _bookingsCollection =>
      _firestore.collection(FirebaseConfig.bookingsCollection);

  CollectionReference get _bikesCollection =>
      _firestore.collection(FirebaseConfig.bikesCollection);

  CollectionReference get _stationsCollection =>
      _firestore.collection(FirebaseConfig.stationsCollection);

  @override
  Future<Booking> createBooking(Booking booking) async {
    final docRef = _bookingsCollection.doc();
    final bookingWithId = booking.copyWith(id: docRef.id);
    final dto = BookingDTO.fromModel(bookingWithId);

    // ATOMIC TRANSACTION (US4)
    // Ensures bike status and station count are updated safely
    await _firestore.runTransaction((transaction) async {
      // 1. Get Bike Doc
      final bikeRef = _bikesCollection.doc(booking.bikeId);
      final bikeDoc = await transaction.get(bikeRef);
      
      if (!bikeDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Bike not found.',
        );
      }

      final bikeStatus = bikeDoc.get('status') as String;
      if (bikeStatus != 'AVAILABLE') {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Bike is no longer available.',
        );
      }

      // 2. Get Station Doc
      final stationRef = _stationsCollection.doc(booking.stationId);
      final stationDoc = await transaction.get(stationRef);

      // 3. Update Bike Status
      transaction.update(bikeRef, {
        'status': 'BOOKED',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // 4. Update Station Count
      if (stationDoc.exists) {
        final currentCount = stationDoc.get('availableBikes') as int;
        transaction.update(stationRef, {
          'availableBikes': currentCount > 0 ? currentCount - 1 : 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      // 5. Create Booking
      transaction.set(docRef, dto.toFirebase());
    });

    return bookingWithId;
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return BookingDTO.fromFirebase(data).toModel();
  }

  @override
  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BookingDTO.fromFirebase(data).toModel();
    }).toList();
  }

  @override
  Future<Booking?> getActiveBookingByUserId(String userId) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ACTIVE')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return BookingDTO.fromFirebase(data).toModel();
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': status.name.toUpperCase(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> completeBooking(
    String bookingId, {
    required DateTime returnDate,
    required double rideDistance,
    required int rideDuration,
  }) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return;

    // ANOTHER TRANSACTION for Returning the bike
    await _firestore.runTransaction((transaction) async {
      // 1. Update Booking
      transaction.update(_bookingsCollection.doc(bookingId), {
        'status': 'COMPLETED',
        'returnDate': returnDate.toIso8601String(),
        'rideDistance': rideDistance,
        'rideDuration': rideDuration,
      });

      // 2. Update Bike Status
      transaction.update(_bikesCollection.doc(booking.bikeId), {
        'status': 'AVAILABLE',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // 3. Update Station Count
      final stationRef = _stationsCollection.doc(booking.stationId);
      final stationDoc = await transaction.get(stationRef);
      if (stationDoc.exists) {
        final currentCount = stationDoc.get('availableBikes') as int;
        transaction.update(stationRef, {
          'availableBikes': currentCount + 1,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return;

    await _firestore.runTransaction((transaction) async {
      transaction.update(_bookingsCollection.doc(bookingId), {'status': 'CANCELLED'});
      transaction.update(_bikesCollection.doc(booking.bikeId), {'status': 'AVAILABLE'});
      
      final stationRef = _stationsCollection.doc(booking.stationId);
      final stationDoc = await transaction.get(stationRef);
      if (stationDoc.exists) {
        final currentCount = stationDoc.get('availableBikes') as int;
        transaction.update(stationRef, {'availableBikes': currentCount + 1});
      }
    });
  }

  @override
  Stream<Booking?> watchActiveBooking(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ACTIVE')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return BookingDTO.fromFirebase(data).toModel();
    });
  }

  @override
  Stream<List<Booking>> watchBookingsByUserId(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BookingDTO.fromFirebase(data).toModel();
      }).toList();
    });
  }

  @override
  Future<List<Booking>> getBookingHistory(String userId, {int limit = 50}) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['COMPLETED', 'CANCELLED'])
        .orderBy('bookingDate', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BookingDTO.fromFirebase(data).toModel();
    }).toList();
  }
}
