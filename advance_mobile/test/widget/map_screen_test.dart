import 'package:advance_mobile/data/repositories/bike/bike_repository.dart';
import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/station/station_repository.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/service_locator.dart';
import 'package:advance_mobile/ui/screens/map/map_screen.dart';
import 'package:advance_mobile/ui/screens/map/view_model/map_viewmodel.dart';
import 'package:advance_mobile/ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('MapScreen', () {
    late MockDataStore store;
    late MockStationRepository stationRepository;
    late MapViewModel mapViewModel;

    setUp(() async {
      await getIt.reset();
      store = MockDataStore();
      stationRepository = MockStationRepository(store);
      mapViewModel = MapViewModel(stationRepository);
      await mapViewModel.initialize();

      getIt.registerLazySingleton<IBikeRepository>(() => MockBikeRepository(store));
      getIt.registerLazySingleton<IStationRepository>(() => stationRepository);
      getIt.registerFactory<StationDetailViewModel>(
        () => StationDetailViewModel(
          getIt<IBikeRepository>(),
          getIt<IStationRepository>(),
        ),
      );
    });

    tearDown(() async {
      mapViewModel.dispose();
      await getIt.reset();
    });

    testWidgets('7.6 renders station markers with availability count', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness(mapViewModel));
      await tester.pumpAndSettle();

      for (final station in mapViewModel.stations) {
        expect(find.byKey(Key('station_marker_${station.id}')), findsOneWidget);
        expect(find.text('${station.availableBikes}'), findsWidgets);
      }
    });

    testWidgets('7.6 station selection highlights marker and shows bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness(mapViewModel));
      await tester.pumpAndSettle();

      final stationId = mapViewModel.stations.first.id;
      await tester.tap(find.byKey(Key('station_marker_$stationId')));
      await tester.pumpAndSettle();

      expect(find.text('SELECTED'), findsOneWidget);
      expect(find.textContaining('Station:'), findsOneWidget);
      expect(find.text('BIKES AVAILABLE'), findsOneWidget);
      expect(find.text('EMPTY SLOTS'), findsOneWidget);

      final selectedColor = _markerCircleColor(tester, stationId);
      expect(selectedColor, const Color(0xFF00C853));
    });

    testWidgets('7.6 view bikes button navigates to StationDetailScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness(mapViewModel));
      await tester.pumpAndSettle();

      final stationId = mapViewModel.stations.first.id;
      await tester.tap(find.byKey(Key('station_marker_$stationId')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('View Available Bike'), findsOneWidget);
    });
  });
}

Widget _buildHarness(MapViewModel mapViewModel) {
  return ChangeNotifierProvider<MapViewModel>.value(
    value: mapViewModel,
    child: MaterialApp(
      home: MapScreen(
        onNavigateToPlans: () {},
        showMapWidget: false,
      ),
    ),
  );
}

Color? _markerCircleColor(WidgetTester tester, String stationId) {
  final markerFinder = find.byKey(Key('station_marker_$stationId'));
  final containers = tester.widgetList<Container>(
    find.descendant(of: markerFinder, matching: find.byType(Container)),
  );

  for (final container in containers) {
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
      return decoration.color;
    }
  }

  return null;
}
