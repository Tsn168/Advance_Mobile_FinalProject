import '../../../model/station/station.dart';
import 'station_repository.dart';
import '../mock_data_store.dart';

class MockStationRepository implements IStationRepository {
  MockStationRepository(this._store);

  final MockDataStore _store;

  @override
  Future<List<Station>> getAllStations() async {
    await _store.simulateNetworkDelay();
    final stations = List<Station>.from(_store.stations);
    stations.sort((a, b) => a.name.compareTo(b.name));
    return stations;
  }

  @override
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    await _store.simulateNetworkDelay();

    final nearby = _store.stations.where((station) {
      final latDelta = (station.latitude - latitude).abs();
      final lngDelta = (station.longitude - longitude).abs();
      final approxDistanceKm = (latDelta + lngDelta) * 111;
      return approxDistanceKm <= radiusKm;
    }).toList();

    nearby.sort((a, b) => b.availableBikes.compareTo(a.availableBikes));
    return nearby;
  }

  @override
  Future<Station?> getStationById(String stationId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.stations.firstWhere((station) => station.id == stationId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Station>> getStationsWithAvailableBikes() async {
    await _store.simulateNetworkDelay();
    return _store.stations
        .where((station) => station.availableBikes > 0)
        .toList();
  }

  @override
  Future<void> updateStationAvailability(
    String stationId,
    int availableBikes,
  ) async {
    await _store.simulateNetworkDelay();

    final index = _store.stations.indexWhere(
      (station) => station.id == stationId,
    );
    if (index == -1) {
      throw Exception('Station not found: $stationId');
    }

    _store.stations[index] = _store.stations[index].copyWith(
      availableBikes: availableBikes,
      lastUpdated: DateTime.now(),
    );
    _store.notifyChanged();
  }

  @override
  Stream<List<Station>> watchAllStations() async* {
    yield await getAllStations();
    await for (final _ in _store.changes) {
      yield await getAllStations();
    }
  }

  @override
  Stream<Station?> watchStation(String stationId) async* {
    yield await getStationById(stationId);
    await for (final _ in _store.changes) {
      yield await getStationById(stationId);
    }
  }
}
