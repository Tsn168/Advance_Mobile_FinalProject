import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../config/firebase_config.dart';
import '../../../model/station/station.dart';
import '../../dtos/station_dto.dart';
import 'station_repository.dart';

class StationRepositoryFirebase implements IStationRepository {
  StationRepositoryFirebase({FirebaseDatabase? database})
    : _database =
          database ?? FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: FirebaseConfig.realtimeDatabaseUrl);

  final FirebaseDatabase _database;

  DatabaseReference get _stationsRef =>
      _database.ref(FirebaseConfig.stationsPath);

  @override
  Future<List<Station>> getAllStations() async {
    final event = await _stationsRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return <Station>[];
    }

    final root = Map<String, dynamic>.from(event.value as Map);
    final stations = <Station>[];
    root.forEach((key, raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      map.putIfAbsent('id', () => key);
      stations.add(StationDTO.fromFirebase(map).toModel());
    });

    stations.sort((a, b) => a.name.compareTo(b.name));
    return stations;
  }

  @override
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    final stations = await getAllStations();
    final nearby = stations.where((station) {
      return _distanceKm(
            latitude,
            longitude,
            station.latitude,
            station.longitude,
          ) <=
          radiusKm;
    }).toList();

    nearby.sort((a, b) => b.availableBikes.compareTo(a.availableBikes));
    return nearby;
  }

  @override
  Future<Station?> getStationById(String stationId) async {
    final event = await _stationsRef
        .child(stationId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(event.value as Map);
    map.putIfAbsent('id', () => stationId);
    return StationDTO.fromFirebase(map).toModel();
  }

  @override
  Future<List<Station>> getStationsWithAvailableBikes() async {
    final stations = await getAllStations();
    return stations.where((station) => station.availableBikes > 0).toList();
  }

  @override
  Future<void> updateStationAvailability(
    String stationId,
    int availableBikes,
  ) async {
    await _stationsRef.child(stationId).update({
      'availableBikes': availableBikes,
      'lastUpdated': DateTime.now().toUtc().toIso8601String(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Stream<List<Station>> watchAllStations() {
    return _stationsRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return <Station>[];
      }

      final root = Map<String, dynamic>.from(value as Map);
      final stations = <Station>[];
      root.forEach((key, raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.putIfAbsent('id', () => key);
        stations.add(StationDTO.fromFirebase(map).toModel());
      });
      stations.sort((a, b) => a.name.compareTo(b.name));
      return stations;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchAllStations error: $error');
    });
  }

  @override
  Stream<Station?> watchStation(String stationId) {
    return _stationsRef.child(stationId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return null;
      }
      final map = Map<String, dynamic>.from(value as Map);
      map.putIfAbsent('id', () => stationId);
      return StationDTO.fromFirebase(map).toModel();
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchStation($stationId) error: $error');
    });
  }

  double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);
}
