import '../../model/pass/pass.dart';

/// Pass DTO - Data Transfer Object for Pass
class PassDTO {
  final String id;
  final String userId;
  final String type; // 'DAY', 'WEEKLY', 'MONTHLY', 'ANNUAL'
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final double price;
  final int ridesUsed;
  final DateTime? createdAt;

  PassDTO({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    required this.price,
    this.ridesUsed = 0,
    this.createdAt,
  });

  /// Convert DTO to Model
  Pass toModel() {
    return Pass(
      id: id,
      userId: userId,
      type: PassType.values.firstWhere(
        (e) => e.toString().split('.').last == type.toLowerCase(),
        orElse: () => PassType.day,
      ),
      startDate: startDate,
      expiryDate: expiryDate,
      isActive: isActive,
      price: price,
      ridesUsed: ridesUsed,
      createdAt: createdAt,
    );
  }

  /// Create DTO from Model
  factory PassDTO.fromModel(Pass pass) {
    return PassDTO(
      id: pass.id,
      userId: pass.userId,
      type: pass.type.name.toUpperCase(),
      startDate: pass.startDate,
      expiryDate: pass.expiryDate,
      isActive: pass.isActive,
      price: pass.price,
      ridesUsed: pass.ridesUsed,
      createdAt: pass.createdAt,
    );
  }

  /// Create DTO from Firebase map
  factory PassDTO.fromFirebase(Map<String, dynamic> map) {
    return PassDTO(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'DAY',
      startDate: map['startDate'] is DateTime
          ? map['startDate']
          : DateTime.parse(map['startDate'] ?? DateTime.now().toString()),
      expiryDate: map['expiryDate'] is DateTime
          ? map['expiryDate']
          : DateTime.parse(map['expiryDate'] ?? DateTime.now().toString()),
      isActive: map['isActive'] ?? false,
      price: (map['price'] ?? 0.0).toDouble(),
      ridesUsed: map['ridesUsed'] ?? 0,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  /// Convert DTO to Firebase map
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'price': price,
      'ridesUsed': ridesUsed,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
