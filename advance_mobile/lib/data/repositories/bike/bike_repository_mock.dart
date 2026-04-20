import '../../../model/bike/bike.dart';
import 'bike_repository.dart';
import '../mock_data_store.dart';

class MockBikeRepository implements IBikeRepository {
  MockBikeRepository(this._store);

  final MockDataStore _store;

  @override
  Future<Bike> createBike(Bike bike) async {
    await _store.simulateNetworkDelay();

    final created = bike.copyWith(
      id: bike.id.isEmpty ? _store.nextId('bike') : bike.id,
      createdAt: bike.createdAt ?? DateTime.now(),
    );
    _store.bikes.add(created);
    _store.syncStationAvailability(created.stationId);
    _store.notifyChanged();
    return created;
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    await _store.simulateNetworkDelay();

    final existing = await getBikeById(bikeId);
    _store.bikes.removeWhere((bike) => bike.id == bikeId);
    if (existing != null) {
      _store.syncStationAvailability(existing.stationId);
    }
    _store.notifyChanged();
  }

  @override
  Future<List<Bike>> getAvailableBikesByStation(String stationId) async {
    await _store.simulateNetworkDelay();
    return _store.bikes.where((bike) {
      return bike.stationId == stationId && bike.status == BikeStatus.available;
    }).toList();
  }

  @override
  Future<Bike?> getBikeById(String bikeId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.bikes.firstWhere((bike) => bike.id == bikeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    await _store.simulateNetworkDelay();
    final bikes = _store.bikes
        .where((bike) => bike.stationId == stationId)
        .toList();
    bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
    return bikes;
  }

  @override
  Future<List<Bike>> getBikesByStatus(BikeStatus status) async {
    await _store.simulateNetworkDelay();
    return _store.bikes.where((bike) => bike.status == status).toList();
  }

  @override
  Future<void> updateBikeCondition(
    String bikeId,
    BikeCondition condition,
  ) async {
    await _store.simulateNetworkDelay();
    final index = _store.bikes.indexWhere((bike) => bike.id == bikeId);
    if (index == -1) {
      throw Exception('Bike not found: $bikeId');
    }
    _store.bikes[index] = _store.bikes[index].copyWith(condition: condition);
    _store.notifyChanged();
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) async {
    await _store.simulateNetworkDelay();
    final index = _store.bikes.indexWhere((bike) => bike.id == bikeId);
    if (index == -1) {
      throw Exception('Bike not found: $bikeId');
    }

    final bike = _store.bikes[index];
    _store.bikes[index] = bike.copyWith(status: status);
    _store.syncStationAvailability(bike.stationId);
    _store.notifyChanged();
  }

  @override
  Stream<Bike?> watchBike(String bikeId) async* {
    yield await getBikeById(bikeId);
    await for (final _ in _store.changes) {
      yield await getBikeById(bikeId);
    }
  }

  @override
  Stream<List<Bike>> watchBikesByStation(String stationId) {
    return Stream<List<Bike>>.periodic(const Duration(seconds: 1), (_) {
      final bikes = _store.bikes
          .where((bike) => bike.stationId == stationId)
          .toList();
      bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
      return bikes;
    });
  }
}
