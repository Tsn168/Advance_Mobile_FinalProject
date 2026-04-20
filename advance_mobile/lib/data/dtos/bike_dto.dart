import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/bike/bike.dart';

/// Bike DTO - Data Transfer Object for Bike
class BikeDTO {
  final String id;
  final String stationId;
  final int slotNumber;
  final String status; // 'AVAILABLE', 'BOOKED', 'MAINTENANCE'
  final String condition; // 'EXCELLENT', 'GOOD', 'FAIR', 'POOR'
  final String model;
  final String? color;
  final int? kmsRidden;
  final DateTime? lastServiced;
  final DateTime? createdAt;

  BikeDTO({
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

  /// Convert DTO to Model
  Bike toModel() {
    return Bike(
      id: id,
      stationId: stationId,
      slotNumber: slotNumber,
      status: BikeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status.toLowerCase(),
        orElse: () => BikeStatus.available,
      ),
      condition: BikeCondition.values.firstWhere(
        (e) => e.toString().split('.').last == condition.toLowerCase(),
        orElse: () => BikeCondition.good,
      ),
      model: model,
      color: color,
      kmsRidden: kmsRidden,
      lastServiced: lastServiced,
      createdAt: createdAt,
    );
  }

  /// Create DTO from Model
  factory BikeDTO.fromModel(Bike bike) {
    return BikeDTO(
      id: bike.id,
      stationId: bike.stationId,
      slotNumber: bike.slotNumber,
      status: bike.status.name.toUpperCase(),
      condition: bike.condition.name.toUpperCase(),
      model: bike.model,
      color: bike.color,
      kmsRidden: bike.kmsRidden,
      lastServiced: bike.lastServiced,
      createdAt: bike.createdAt,
    );
  }

  /// Create DTO from Firebase map
  factory BikeDTO.fromFirebase(Map<String, dynamic> map) {
    return BikeDTO(
      id: map['id'] ?? '',
      stationId: map['stationId'] ?? '',
      slotNumber: map['slotNumber'] ?? 0,
      status: map['status'] ?? 'AVAILABLE',
      condition: map['condition'] ?? 'GOOD',
      model: map['model'] ?? '',
      color: map['color'],
      kmsRidden: map['kmsRidden'],
      lastServiced: _parseDateTime(map['lastServiced'])?.toUtc(),
      createdAt: _parseDateTime(map['createdAt'])?.toUtc(),
    );
  }

  /// Convert DTO to Firebase map
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'stationId': stationId,
      'slotNumber': slotNumber,
      'status': status,
      'condition': condition,
      'model': model,
      'color': color,
      'kmsRidden': kmsRidden,
      'lastServiced': lastServiced?.toUtc().toIso8601String(),
      'createdAt': createdAt?.toUtc().toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
