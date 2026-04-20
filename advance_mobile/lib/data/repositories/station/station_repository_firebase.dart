import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/station/station.dart';
import '../../dtos/station_dto.dart';
import 'station_repository.dart';
import '../../../config/firebase_config.dart';

/// Real Firebase implementation of the Station Repository.
class StationRepositoryFirebase implements IStationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _stationsCollection =>
      _firestore.collection(FirebaseConfig.stationsCollection);

  @override
  Future<List<Station>> getAllStations() async {
    final snapshot = await _stationsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return StationDTO.fromFirebase(data).toModel();
    }).toList();
  }

  @override
  Future<Station?> getStationById(String stationId) async {
    final doc = await _stationsCollection.doc(stationId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return StationDTO.fromFirebase(data).toModel();
  }

  @override
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    // For a real production app, use Geohashing (e.g., geoflutterfire).
    // For this project, we fetch all and filter in memory to keep it simple.
    final allStations = await getAllStations();
    
    return allStations.where((station) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  @override
  Future<void> updateStationAvailability(String stationId, int availableBikes) async {
    await _stationsCollection.doc(stationId).update({
      'availableBikes': availableBikes,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<Station>> watchAllStations() {
    return _stationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StationDTO.fromFirebase(data).toModel();
      }).toList();
    });
  }

  @override
  Stream<Station?> watchStation(String stationId) {
    return _stationsCollection.doc(stationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return StationDTO.fromFirebase(data).toModel();
    });
  }

  @override
  Future<List<Station>> getStationsWithAvailableBikes() async {
    final snapshot = await _stationsCollection
        .where('availableBikes', isGreaterThan: 0)
        .get();
        
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return StationDTO.fromFirebase(data).toModel();
    }).toList();
  }

  /// Haversine formula to calculate distance between two coordinates in KM
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
