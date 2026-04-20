/// Booking Status Enum
enum BookingStatus {
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Booking Model - Represents a bike booking
class Booking {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final int slotNumber;
  final DateTime bookingDate;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final BookingStatus status;
  final double? rideDistance;
  final int? rideDuration; // in minutes

  Booking({
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

  /// Check if booking is active
  bool get isActive => status == BookingStatus.active;

  /// Get booking duration in minutes
  int? get bookingDurationMinutes {
    if (pickupDate != null && returnDate != null) {
      return returnDate!.difference(pickupDate!).inMinutes;
    }
    return null;
  }

  /// Copy with method for immutability
  Booking copyWith({
    String? id,
    String? userId,
    String? bikeId,
    String? stationId,
    int? slotNumber,
    DateTime? bookingDate,
    DateTime? pickupDate,
    DateTime? returnDate,
    BookingStatus? status,
    double? rideDistance,
    int? rideDuration,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bikeId: bikeId ?? this.bikeId,
      stationId: stationId ?? this.stationId,
      slotNumber: slotNumber ?? this.slotNumber,
      bookingDate: bookingDate ?? this.bookingDate,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      rideDistance: rideDistance ?? this.rideDistance,
      rideDuration: rideDuration ?? this.rideDuration,
    );
  }

  @override
  String toString() =>
      'Booking(id: $id, bikeId: $bikeId, status: ${status.displayName})';
}
