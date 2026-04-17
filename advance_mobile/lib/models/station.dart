/// Station Model - Represents a bike sharing station
class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int totalSlots;
  final int availableBikes;
  final String? address;
  final String? imageUrl;
  final DateTime? lastUpdated;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.totalSlots,
    required this.availableBikes,
    this.address,
    this.imageUrl,
    this.lastUpdated,
  });

  /// Get occupied slots count
  int get occupiedSlots => totalSlots - availableBikes;

  /// Check if station has available bikes
  bool get hasAvailableBikes => availableBikes > 0;

  /// Get availability percentage
  double get availabilityPercentage =>
      (availableBikes / totalSlots * 100).roundToDouble();

  /// Copy with method for immutability
  Station copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? totalSlots,
    int? availableBikes,
    String? address,
    String? imageUrl,
    DateTime? lastUpdated,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSlots: totalSlots ?? this.totalSlots,
      availableBikes: availableBikes ?? this.availableBikes,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() =>
      'Station(id: $id, name: $name, availableBikes: $availableBikes)';
}
