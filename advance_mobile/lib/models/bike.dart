/// Bike Status Enum
enum BikeStatus {
  available,
  booked,
  maintenance;

  String get displayName {
    switch (this) {
      case BikeStatus.available:
        return 'Available';
      case BikeStatus.booked:
        return 'Booked';
      case BikeStatus.maintenance:
        return 'Maintenance';
    }
  }
}

/// Bike Condition Enum
enum BikeCondition {
  excellent,
  good,
  fair,
  poor;

  String get displayName {
    switch (this) {
      case BikeCondition.excellent:
        return 'Excellent';
      case BikeCondition.good:
        return 'Good';
      case BikeCondition.fair:
        return 'Fair';
      case BikeCondition.poor:
        return 'Poor';
    }
  }
}

/// Bike Model - Represents a bike at a station
class Bike {
  final String id;
  final String stationId;
  final int slotNumber;
  final BikeStatus status;
  final BikeCondition condition;
  final String model;
  final String? color;
  final int? kmsRidden;
  final DateTime? lastServiced;
  final DateTime? createdAt;

  Bike({
    required this.id,
    required this.stationId,
    required this.slotNumber,
    required this.status,
    required this.condition,
    required this.model,
    this.color,
    this.kmsRidden,
    this.lastServiced,
    this.createdAt,
  });

  /// Check if bike is available for booking
  bool get isAvailable => status == BikeStatus.available;

  /// Copy with method for immutability
  Bike copyWith({
    String? id,
    String? stationId,
    int? slotNumber,
    BikeStatus? status,
    BikeCondition? condition,
    String? model,
    String? color,
    int? kmsRidden,
    DateTime? lastServiced,
    DateTime? createdAt,
  }) {
    return Bike(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      slotNumber: slotNumber ?? this.slotNumber,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      model: model ?? this.model,
      color: color ?? this.color,
      kmsRidden: kmsRidden ?? this.kmsRidden,
      lastServiced: lastServiced ?? this.lastServiced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Bike(id: $id, slotNumber: $slotNumber, status: ${status.displayName})';
}
