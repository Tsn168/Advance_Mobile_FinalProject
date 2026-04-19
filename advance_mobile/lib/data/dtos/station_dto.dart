import '../../model/station/station.dart';

/// Station DTO - Data Transfer Object for Station
class StationDTO {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int totalSlots;
  final int availableBikes;
  final String? address;
  final String? imageUrl;
  final DateTime? lastUpdated;

  StationDTO({
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

  /// Convert DTO to Model
  Station toModel() {
    return Station(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      totalSlots: totalSlots,
      availableBikes: availableBikes,
      address: address,
      imageUrl: imageUrl,
      lastUpdated: lastUpdated,
    );
  }

  /// Create DTO from Model
  factory StationDTO.fromModel(Station station) {
    return StationDTO(
      id: station.id,
      name: station.name,
      latitude: station.latitude,
      longitude: station.longitude,
      totalSlots: station.totalSlots,
      availableBikes: station.availableBikes,
      address: station.address,
      imageUrl: station.imageUrl,
      lastUpdated: station.lastUpdated,
    );
  }

  /// Create DTO from Firebase map
  factory StationDTO.fromFirebase(Map<String, dynamic> map) {
    return StationDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      totalSlots: map['totalSlots'] ?? 0,
      availableBikes: map['availableBikes'] ?? 0,
      address: map['address'],
      imageUrl: map['imageUrl'],
      lastUpdated: map['lastUpdated'] is DateTime
          ? map['lastUpdated']
          : map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  /// Convert DTO to Firebase map
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'totalSlots': totalSlots,
      'availableBikes': availableBikes,
      'address': address,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}
