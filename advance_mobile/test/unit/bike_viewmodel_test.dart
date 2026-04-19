import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/ui/screens/map/view_model/bike_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BikeViewModel', () {
    late MockDataStore store;
    late MockBikeRepository bikeRepository;
    late BikeViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      bikeRepository = MockBikeRepository(store);
      viewModel = BikeViewModel(bikeRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test(
      'loadBikesByStation loads station bikes and available subset',
      () async {
        await viewModel.loadBikesByStation('station_central');

        expect(viewModel.bikes, isNotEmpty);
        expect(
          viewModel.availableBikes.length,
          lessThanOrEqualTo(viewModel.bikes.length),
        );
        expect(viewModel.stationId, 'station_central');
      },
    );

    test('watch stream reflects bike status updates', () async {
      await viewModel.loadBikesByStation('station_central');

      final initialAvailable = viewModel.availableBikes.length;
      await bikeRepository.updateBikeStatus('bike_c1', BikeStatus.booked);
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(viewModel.availableBikes.length, lessThan(initialAvailable));
    });
  });
}
