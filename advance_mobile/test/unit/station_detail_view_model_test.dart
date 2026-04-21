import 'dart:async';

import 'package:advance_mobile/config/app_constants.dart';
import 'package:advance_mobile/data/repositories/bike/bike_repository.dart';
import 'package:advance_mobile/data/repositories/station/station_repository.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/station/station.dart';
import 'package:advance_mobile/ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationDetailViewModel', () {
    late _FakeBikeRepository bikeRepository;
    late _FakeStationRepository stationRepository;
    late StationDetailViewModel viewModel;

    final station = Station(
      id: 'station_1',
      name: 'Central Station',
      latitude: 11.0,
      longitude: 104.0,
      totalSlots: 5,
      availableBikes: 2,
      address: 'Central',
    );

    final bike1 = Bike(
      id: 'bike_1',
      stationId: 'station_1',
      slotNumber: 1,
      status: BikeStatus.available,
      condition: BikeCondition.good,
      model: 'Model A',
    );

    final bike2 = Bike(
      id: 'bike_2',
      stationId: 'station_1',
      slotNumber: 2,
      status: BikeStatus.booked,
      condition: BikeCondition.good,
      model: 'Model B',
    );

    setUp(() {
      bikeRepository = _FakeBikeRepository(
        stationBikes: {
          'station_1': [bike1, bike2],
        },
      );
      stationRepository = _FakeStationRepository(
        stations: {
          'station_1': station,
        },
      );
      viewModel = StationDetailViewModel(bikeRepository, stationRepository);
    });

    tearDown(() {
      viewModel.dispose();
      bikeRepository.dispose();
    });

    test('state transitions idle -> loading -> success', () async {
      final states = <AppState>[];
      viewModel.addListener(() {
        states.add(viewModel.state);
      });

      final loadFuture = viewModel.loadStationDetails('station_1');

      expect(viewModel.state, AppState.loading);

      await loadFuture;

      expect(states.first, AppState.loading);
      expect(states.last, AppState.success);
      expect(viewModel.station?.id, 'station_1');
      expect(viewModel.bikes.length, 2);
      expect(viewModel.availableBikes.length, 1);
      expect(viewModel.unavailableBikes.length, 1);
      expect(viewModel.totalSlots, 5);
      expect(viewModel.occupiedSlots, 2);
      expect(viewModel.emptySlots, 3);
    });

    test('state transitions loading -> error when loading fails', () async {
      final failingStationRepository = _FakeStationRepository(
        stations: const {},
        getByIdError: Exception('Station fetch failed'),
      );
      final failingViewModel = StationDetailViewModel(
        bikeRepository,
        failingStationRepository,
      );
      addTearDown(failingViewModel.dispose);

      final states = <AppState>[];
      failingViewModel.addListener(() {
        states.add(failingViewModel.state);
      });

      await failingViewModel.loadStationDetails('station_1');

      expect(states.first, AppState.loading);
      expect(states.last, AppState.error);
      expect(failingViewModel.state, AppState.error);
      expect(failingViewModel.errorMessage, contains('Station fetch failed'));
    });

    test('selectBike and clearSelection update selectedBike', () async {
      await viewModel.loadStationDetails('station_1');

      viewModel.selectBike('bike_1');
      expect(viewModel.selectedBike, isNotNull);
      expect(viewModel.selectedBike?.id, 'bike_1');

      viewModel.clearSelection();
      expect(viewModel.selectedBike, isNull);
    });

    test('realtime bike updates are reflected from stream', () async {
      await viewModel.loadStationDetails('station_1');
      viewModel.selectBike('bike_1');

      bikeRepository.emitForStation('station_1', [
        bike1.copyWith(status: BikeStatus.booked),
        bike2,
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.bikes.length, 2);
      expect(viewModel.availableBikes.length, 0);
      expect(viewModel.unavailableBikes.length, 2);
      expect(viewModel.selectedBike?.id, 'bike_1');
      expect(viewModel.selectedBike?.status, BikeStatus.booked);
    });

    test('13.1 refreshBikes recovers from transient error', () async {
      final flakyRepository = _FlakyBikeRepository(
        stationBikes: {
          'station_1': [bike1, bike2],
        },
      );
      final vm = StationDetailViewModel(flakyRepository, stationRepository);
      addTearDown(() {
        vm.dispose();
        flakyRepository.dispose();
      });

      await vm.loadStationDetails('station_1');
      expect(vm.state, AppState.success);

      await vm.refreshBikes();
      expect(vm.state, AppState.error);
      expect(vm.errorMessage, contains('Transient network error'));

      await vm.refreshBikes();
      expect(vm.state, AppState.success);
      expect(vm.bikes.length, 2);
    });

    test('13.6 stream error transitions to error state', () async {
      await viewModel.loadStationDetails('station_1');
      bikeRepository.emitError('station_1', Exception('Live stream disconnected'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(viewModel.state, AppState.error);
      expect(viewModel.errorMessage, contains('Live stream disconnected'));
    });

    test('14.3 dispose cancels active realtime subscription', () async {
      await viewModel.loadStationDetails('station_1');
      expect(bikeRepository.activeListenerCount('station_1'), 1);

      viewModel.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bikeRepository.activeListenerCount('station_1'), 0);
    });
  });
}

class _FakeBikeRepository implements IBikeRepository {
  _FakeBikeRepository({
    required Map<String, List<Bike>> stationBikes,
    this.getByStationError,
  }) : _stationBikes = stationBikes;

  final Map<String, List<Bike>> _stationBikes;
  final Object? getByStationError;
  final Map<String, StreamController<List<Bike>>> _controllers = {};

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    if (getByStationError != null) {
      throw getByStationError!;
    }
    return List<Bike>.from(_stationBikes[stationId] ?? const []);
  }

  @override
  Stream<List<Bike>> watchBikesByStation(String stationId) {
    final controller = _controllers.putIfAbsent(
      stationId,
      () => StreamController<List<Bike>>.broadcast(
        onListen: () {
          _activeListeners[stationId] = (_activeListeners[stationId] ?? 0) + 1;
        },
        onCancel: () {
          final current = _activeListeners[stationId] ?? 0;
          _activeListeners[stationId] = current > 0 ? current - 1 : 0;
        },
      ),
    );
    return controller.stream;
  }

  void emitForStation(String stationId, List<Bike> bikes) {
    _stationBikes[stationId] = List<Bike>.from(bikes);
    final controller = _controllers.putIfAbsent(
      stationId,
      () => StreamController<List<Bike>>.broadcast(),
    );
    controller.add(List<Bike>.from(bikes));
  }

  void emitError(String stationId, Object error) {
    final controller = _controllers.putIfAbsent(
      stationId,
      () => StreamController<List<Bike>>.broadcast(),
    );
    controller.addError(error);
  }

  final Map<String, int> _activeListeners = {};

  int activeListenerCount(String stationId) => _activeListeners[stationId] ?? 0;

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  @override
  Future<List<Bike>> getAvailableBikesByStation(String stationId) {
    throw UnimplementedError();
  }

  @override
  Future<Bike?> getBikeById(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateBikeCondition(String bikeId, BikeCondition condition) {
    throw UnimplementedError();
  }

  @override
  Future<Bike> createBike(Bike bike) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBike(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Stream<Bike?> watchBike(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Bike>> getBikesByStatus(BikeStatus status) {
    throw UnimplementedError();
  }
}

class _FakeStationRepository implements IStationRepository {
  _FakeStationRepository({required Map<String, Station> stations, this.getByIdError})
      : _stations = stations;

  final Map<String, Station> _stations;
  final Object? getByIdError;

  @override
  Future<Station?> getStationById(String stationId) async {
    if (getByIdError != null) {
      throw getByIdError!;
    }
    return _stations[stationId];
  }

  @override
  Future<List<Station>> getAllStations() {
    throw UnimplementedError();
  }

  @override
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateStationAvailability(String stationId, int availableBikes) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Station>> watchAllStations() {
    throw UnimplementedError();
  }

  @override
  Stream<Station?> watchStation(String stationId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Station>> getStationsWithAvailableBikes() {
    throw UnimplementedError();
  }
}

class _FlakyBikeRepository extends _FakeBikeRepository {
  _FlakyBikeRepository({required super.stationBikes});

  var _refreshAttempt = 0;

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    _refreshAttempt += 1;
    if (_refreshAttempt == 2) {
      throw Exception('Transient network error');
    }
    return super.getBikesByStation(stationId);
  }
}
