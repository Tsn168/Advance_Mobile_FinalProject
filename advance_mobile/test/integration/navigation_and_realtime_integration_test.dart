import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/service_locator.dart';
import 'package:advance_mobile/ui/screens/map/view_model/booking_viewmodel.dart';
import 'package:advance_mobile/ui/screens/map/map_screen.dart';
import 'package:advance_mobile/ui/screens/map/view_model/map_viewmodel.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:advance_mobile/ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('12.5 + 14.5 integration flows', () {
    late MockDataStore store;
    late MockBikeRepository bikeRepository;
    late MockStationRepository stationRepository;
    late MockPassRepository passRepository;
    late MockBookingRepository bookingRepository;
    late PassViewModel passViewModel;
    late BookingViewModel bookingViewModel;
    late MapViewModel mapViewModel;

    setUp(() async {
      await getIt.reset();
      store = MockDataStore();
      bikeRepository = MockBikeRepository(store);
      stationRepository = MockStationRepository(store);
      passRepository = MockPassRepository(store);
      bookingRepository = MockBookingRepository(store);

      passViewModel = PassViewModel(passRepository, MockUserRepository(store));
      bookingViewModel = BookingViewModel(
        bookingRepository,
        passRepository,
        bikeRepository: bikeRepository,
        stationRepository: stationRepository,
      );
      mapViewModel = MapViewModel(stationRepository);

      getIt.registerFactory<StationDetailViewModel>(
        () => StationDetailViewModel(bikeRepository, stationRepository),
      );
    });

    tearDown(() async {
      passViewModel.dispose();
      bookingViewModel.dispose();
      mapViewModel.dispose();
      await getIt.reset();
    });

    testWidgets('Map -> Station Detail -> Booking confirmation -> success', (
      tester,
    ) async {
      await passViewModel.initialize(userId: 'user_reyu');
      await bookingViewModel.initialize(userId: 'user_reyu');
      await mapViewModel.initialize();

      await tester.pumpWidget(
        _buildHarness(mapViewModel, bookingViewModel, passViewModel),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('station_marker_station_central')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BikeID: #bike_c1'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Booking'), findsWidgets);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Booking'));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      expect(bookingViewModel.activeBooking, isNotNull);
      expect(find.text('Tap a station marker'), findsOneWidget);
    });

    testWidgets('No pass flow returns from plans and keeps booking context', (
      tester,
    ) async {
      await passViewModel.initialize(userId: 'user_elite');
      await bookingViewModel.initialize(userId: 'user_elite');
      await mapViewModel.initialize();

      await tester.pumpWidget(
        _buildHarness(mapViewModel, bookingViewModel, passViewModel),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('station_marker_station_terminal')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BikeID: #bike_t1'));
      await tester.pumpAndSettle();

      expect(find.text('No Active Pass'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Go to Plans'));
      await tester.pumpAndSettle();
      expect(find.text('Manage your subscription'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Station: Terminal Station'), findsOneWidget);
      expect(find.text('Bike: #bike_t1'), findsOneWidget);
    });

    testWidgets('Bike unavailable shows error and returns to station detail', (
      tester,
    ) async {
      await passViewModel.initialize(userId: 'user_reyu');
      await bookingViewModel.initialize(userId: 'user_reyu');
      await mapViewModel.initialize();

      await tester.pumpWidget(
        _buildHarness(mapViewModel, bookingViewModel, passViewModel),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('station_marker_station_central')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BikeID: #bike_c1'));
      await tester.pumpAndSettle();

      await bikeRepository.updateBikeStatus('bike_c1', BikeStatus.booked);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Booking'));
      await tester.pumpAndSettle();

      expect(find.text('Bike Unavailable'), findsOneWidget);
      await tester.tap(find.text('Back to Station'));
      await tester.pumpAndSettle();

      expect(find.text('View Available Bike'), findsOneWidget);
      expect(find.text('UNAVAILABLE'), findsWidgets);
    });

    testWidgets('Realtime updates propagate to map and station detail UI', (
      tester,
    ) async {
      await passViewModel.initialize(userId: 'user_reyu');
      await bookingViewModel.initialize(userId: 'user_reyu');
      await mapViewModel.initialize();

      await tester.pumpWidget(
        _buildHarness(mapViewModel, bookingViewModel, passViewModel),
      );
      await tester.pumpAndSettle();

      await stationRepository.updateStationAvailability('station_central', 9);
      await tester.pump(const Duration(milliseconds: 400));

      final centralMarker = find.byKey(const Key('station_marker_station_central'));
      expect(
        find.descendant(of: centralMarker, matching: find.text('9')),
        findsOneWidget,
      );

      await tester.tap(centralMarker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pumpAndSettle();

      expect(find.text('AVAILABLE'), findsWidgets);
      await bikeRepository.updateBikeStatus('bike_c2', BikeStatus.booked);
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('UNAVAILABLE'), findsWidgets);
    });
  });
}

Widget _buildHarness(
  MapViewModel mapViewModel,
  BookingViewModel bookingViewModel,
  PassViewModel passViewModel,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<MapViewModel>.value(value: mapViewModel),
      ChangeNotifierProvider<BookingViewModel>.value(value: bookingViewModel),
      ChangeNotifierProvider<PassViewModel>.value(value: passViewModel),
    ],
    child: const MaterialApp(
      home: MapScreen(
        onNavigateToPlans: _noop,
        showMapWidget: false,
      ),
    ),
  );
}

void _noop() {}
