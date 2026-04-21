/// Pass Types Enum
enum PassType {
  day,
  weekly,
  monthly,
  annual;

  String get displayName {
    switch (this) {
      case PassType.day:
        return 'Day Pass';
      case PassType.weekly:
        return 'Weekly Pass';
      case PassType.monthly:
        return 'Monthly Pass';
      case PassType.annual:
        return 'Annual Pass';
    }
  }

  double get price {
    switch (this) {
      case PassType.day:
        return 5.99;
      case PassType.weekly:
        return 19.99;
      case PassType.monthly:
        return 49.99;
      case PassType.annual:
        return 499.99;
    }
  }

  int get durationDays {
    switch (this) {
      case PassType.day:
        return 1;
      case PassType.weekly:
        return 7;
      case PassType.monthly:
        return 30;
      case PassType.annual:
        return 365;
    }
  }
}

/// Pass Model - Represents a bike sharing pass
class Pass {
  final String id;
  final String userId;
  final PassType type;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final double price;
  final int ridesUsed;
  final DateTime? createdAt;

  Pass({
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

  /// Check if pass is expired
  bool get isExpired {
    final nowUtc = DateTime.now().toUtc();
    final expiryUtc = expiryDate.toUtc();
    return !nowUtc.isBefore(expiryUtc);
  }

  /// Get remaining days
  int get remainingDays {
    final difference = expiryDate
        .toUtc()
        .difference(DateTime.now().toUtc())
        .inDays;
    return difference > 0 ? difference : 0;
  }

  /// Copy with method for immutability
  Pass copyWith({
    String? id,
    String? userId,
    PassType? type,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? isActive,
    double? price,
    int? ridesUsed,
    DateTime? createdAt,
  }) {
    return Pass(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      ridesUsed: ridesUsed ?? this.ridesUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Pass(id: $id, type: ${type.displayName}, isActive: $isActive)';
}
