import '../../model/booking/booking.dart';

/// Booking DTO - Data Transfer Object for Booking
class BookingDTO {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final int slotNumber;
  final DateTime bookingDate;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final String status; // 'ACTIVE', 'COMPLETED', 'CANCELLED'
  final double? rideDistance;
  final int? rideDuration;

  BookingDTO({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.slotNumber,
    required this.bookingDate,
    this.pickupDate,
    this.returnDate,
    required this.status,
    this.rideDistance,
    this.rideDuration,
  });

  /// Convert DTO to Model
  Booking toModel() {
    return Booking(
      id: id,
      userId: userId,
      bikeId: bikeId,
      stationId: stationId,
      slotNumber: slotNumber,
      bookingDate: bookingDate,
      pickupDate: pickupDate,
      returnDate: returnDate,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status.toLowerCase(),
        orElse: () => BookingStatus.active,
      ),
      rideDistance: rideDistance,
      rideDuration: rideDuration,
    );
  }

  /// Create DTO from Model
  factory BookingDTO.fromModel(Booking booking) {
    return BookingDTO(
      id: booking.id,
      userId: booking.userId,
      bikeId: booking.bikeId,
      stationId: booking.stationId,
      slotNumber: booking.slotNumber,
      bookingDate: booking.bookingDate,
      pickupDate: booking.pickupDate,
      returnDate: booking.returnDate,
      status: booking.status.name.toUpperCase(),
      rideDistance: booking.rideDistance,
      rideDuration: booking.rideDuration,
    );
  }

  /// Create DTO from Firebase map
  factory BookingDTO.fromFirebase(Map<String, dynamic> map) {
    return BookingDTO(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bikeId: map['bikeId'] ?? '',
      stationId: map['stationId'] ?? '',
      slotNumber: map['slotNumber'] ?? 0,
      bookingDate: map['bookingDate'] is DateTime
          ? map['bookingDate']
          : DateTime.parse(map['bookingDate'] ?? DateTime.now().toString()),
      pickupDate: map['pickupDate'] is DateTime
          ? map['pickupDate']
          : map['pickupDate'] != null
          ? DateTime.parse(map['pickupDate'])
          : null,
      returnDate: map['returnDate'] is DateTime
          ? map['returnDate']
          : map['returnDate'] != null
          ? DateTime.parse(map['returnDate'])
          : null,
      status: map['status'] ?? 'ACTIVE',
      rideDistance: (map['rideDistance'] ?? 0.0).toDouble(),
      rideDuration: map['rideDuration'],
    );
  }

  /// Convert DTO to Firebase map
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'userId': userId,
      'bikeId': bikeId,
      'stationId': stationId,
      'slotNumber': slotNumber,
      'bookingDate': bookingDate.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status,
      'rideDistance': rideDistance,
      'rideDuration': rideDuration,
    };
  }
}
