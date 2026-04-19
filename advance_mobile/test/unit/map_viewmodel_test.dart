import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/ui/screens/map/view_model/map_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapViewModel', () {
    late MockDataStore store;
    late MockStationRepository stationRepository;
    late MapViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      stationRepository = MockStationRepository(store);
      viewModel = MapViewModel(stationRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initialize listens and loads stations', () async {
      await viewModel.initialize();

      expect(viewModel.stations, isNotEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('selectStation updates selected station', () async {
      await viewModel.initialize();

      final firstStationId = viewModel.stations.first.id;
      viewModel.selectStation(firstStationId);

      expect(viewModel.selectedStation, isNotNull);
      expect(viewModel.selectedStation?.id, firstStationId);
    });

    test('stream updates station availability changes', () async {
      await viewModel.initialize();

      const stationId = 'station_central';
      await stationRepository.updateStationAvailability(stationId, 9);
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final station = viewModel.stations.firstWhere(
        (item) => item.id == stationId,
      );
      expect(station.availableBikes, 9);
    });
  });
}
