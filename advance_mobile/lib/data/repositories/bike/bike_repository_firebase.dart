import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../config/firebase_config.dart';
import '../../../model/bike/bike.dart';
import '../../dtos/bike_dto.dart';
import 'bike_repository.dart';

class BikeRepositoryFirebase implements IBikeRepository {
  BikeRepositoryFirebase({FirebaseDatabase? database})
    : _database =
          database ?? FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: FirebaseConfig.realtimeDatabaseUrl);

  final FirebaseDatabase _database;

  DatabaseReference get _bikesRef => _database.ref(FirebaseConfig.bikesPath);

  @override
  Future<Bike> createBike(Bike bike) async {
    final key = bike.id.isEmpty ? _bikesRef.push().key : bike.id;
    if (key == null || key.isEmpty) {
      throw Exception('Unable to generate bike ID');
    }

    final bikeWithId = bike.copyWith(id: key);
    final dto = BikeDTO.fromModel(bikeWithId);
    await _bikesRef
        .child(key)
        .set(dto.toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);
    return dto.toModel();
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    await _bikesRef.child(bikeId).remove().timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Future<List<Bike>> getAvailableBikesByStation(String stationId) async {
    final bikes = await getBikesByStation(stationId);
    return bikes.where((bike) => bike.status == BikeStatus.available).toList();
  }

  @override
  Future<Bike?> getBikeById(String bikeId) async {
    final event = await _bikesRef
        .child(bikeId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(event.value as Map);
    map.putIfAbsent('id', () => bikeId);
    return BikeDTO.fromFirebase(map).toModel();
  }

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    final event = await _bikesRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return <Bike>[];
    }

    final root = Map<String, dynamic>.from(event.value as Map);
    final bikes = <Bike>[];
    root.forEach((key, raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      map.putIfAbsent('id', () => key);
      final bike = BikeDTO.fromFirebase(map).toModel();
      if (bike.stationId == stationId) {
        bikes.add(bike);
      }
    });

    bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
    return bikes;
  }

  @override
  Future<List<Bike>> getBikesByStatus(BikeStatus status) async {
    final event = await _bikesRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return <Bike>[];
    }

    final root = Map<String, dynamic>.from(event.value as Map);
    final bikes = <Bike>[];
    root.forEach((key, raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      map.putIfAbsent('id', () => key);
      final bike = BikeDTO.fromFirebase(map).toModel();
      if (bike.status == status) {
        bikes.add(bike);
      }
    });
    bikes.sort((a, b) {
      final stationDiff = a.stationId.compareTo(b.stationId);
      if (stationDiff != 0) {
        return stationDiff;
      }
      return a.slotNumber.compareTo(b.slotNumber);
    });
    return bikes;
  }

  @override
  Future<void> updateBikeCondition(String bikeId, BikeCondition condition) async {
    await _bikesRef.child(bikeId).update({
      'condition': condition.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) async {
    await _bikesRef.child(bikeId).update({
      'status': status.name.toUpperCase(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Stream<Bike?> watchBike(String bikeId) {
    return _bikesRef.child(bikeId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return null;
      }
      final map = Map<String, dynamic>.from(value as Map);
      map.putIfAbsent('id', () => bikeId);
      return BikeDTO.fromFirebase(map).toModel();
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchBike($bikeId) error: $error');
    });
  }

  @override
  Stream<List<Bike>> watchBikesByStation(String stationId) {
    return _bikesRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return <Bike>[];
      }

      final root = Map<String, dynamic>.from(value as Map);
      final bikes = <Bike>[];
      root.forEach((key, raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.putIfAbsent('id', () => key);
        final bike = BikeDTO.fromFirebase(map).toModel();
        if (bike.stationId == stationId) {
          bikes.add(bike);
        }
      });

      bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      return bikes;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchBikesByStation($stationId) error: $error');
    });
  }
}
