import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/model/station/station.dart';
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

    test('7.7 Property 9: all stations in repository appear as markers', () async {
      // Feature: bike-rental-pass-booking, Property 9: All Stations Displayed
      const stationCounts = [1, 5, 12, 25, 50];

      for (final count in stationCounts) {
        store.stations
          ..clear()
          ..addAll(
            List.generate(count, (index) {
              return Station(
                id: 'station_$count\_$index',
                name: 'Station $index',
                latitude: 11.5 + (index * 0.001),
                longitude: 104.9 + (index * 0.001),
                totalSlots: 20,
                availableBikes: index % 7,
                address: 'Address $index',
              );
            }),
          );

        await viewModel.initialize();

        final markerIds = viewModel.markers
            .map((marker) => marker.markerId.value)
            .toSet();
        final stationIds = store.stations.map((station) => station.id).toSet();

        expect(markerIds.length, count);
        expect(markerIds, stationIds);
      }
    });

    test('7.8 Property 10: marker availability count matches station data', () async {
      // Feature: bike-rental-pass-booking, Property 10: Station Availability Count Display
      store.stations
        ..clear()
        ..addAll(
          List.generate(21, (index) {
            return Station(
              id: 'station_count_$index',
              name: 'Station Count $index',
              latitude: 11.56 + (index * 0.0005),
              longitude: 104.92 + (index * 0.0005),
              totalSlots: 20,
              availableBikes: index,
              address: 'Count Address $index',
            );
          }),
        );

      await viewModel.initialize();

      for (final station in store.stations) {
        final marker = viewModel.markers.firstWhere(
          (item) => item.markerId.value == station.id,
        );
        expect(marker.infoWindow.title, '${station.availableBikes} bikes');
      }
    });

    test(
      '7.9 Property 11: stations with/without availability are visually distinct',
      () async {
        // Feature: bike-rental-pass-booking, Property 11: Station Visual Distinction by Availability
        store.stations
          ..clear()
          ..addAll([
            Station(
              id: 'station_with_bikes',
              name: 'With Bikes',
              latitude: 11.56,
              longitude: 104.92,
              totalSlots: 20,
              availableBikes: 8,
              address: 'With Bikes Address',
            ),
            Station(
              id: 'station_without_bikes',
              name: 'Without Bikes',
              latitude: 11.57,
              longitude: 104.93,
              totalSlots: 20,
              availableBikes: 0,
              address: 'Without Bikes Address',
            ),
          ]);

        await viewModel.initialize();

        final markerWith = viewModel.markers.firstWhere(
          (item) => item.markerId.value == 'station_with_bikes',
        );
        final markerWithout = viewModel.markers.firstWhere(
          (item) => item.markerId.value == 'station_without_bikes',
        );

        expect(markerWith.alpha, isNot(markerWithout.alpha));
        expect(markerWith.alpha, greaterThan(markerWithout.alpha));

        viewModel.selectStation('station_with_bikes');
        final selectedMarker = viewModel.markers.firstWhere(
          (item) => item.markerId.value == 'station_with_bikes',
        );
        expect(selectedMarker.alpha, 1.0);
      },
    );
  });
}
