import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/pass/pass.dart';
import 'package:advance_mobile/model/station/station.dart';
import 'package:advance_mobile/ui/screens/booking_confirmation/booking_confirmation_screen.dart';
import 'package:advance_mobile/ui/screens/home/view_model/booking_viewmodel.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:advance_mobile/ui/states/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('BookingConfirmationScreen', () {
    testWidgets('5.1 summary layout shows station and bike details', (
      tester,
    ) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_reyu'),
      ))!;
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Confirm Booking'), findsWidgets);
      expect(find.text('Booking Summary'), findsOneWidget);
      expect(find.text('Station: ${harness.station.name}'), findsOneWidget);
      expect(find.text('Bike: #${harness.bike.id}'), findsOneWidget);
      expect(find.text('Slot: ${harness.bike.slotNumber}'), findsOneWidget);
      expect(find.textContaining('Model:'), findsOneWidget);
      expect(find.textContaining('Condition:'), findsOneWidget);
    });

    testWidgets('5.2/5.3 active pass state shows confirm booking button', (
      tester,
    ) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_reyu'),
      ))!;
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Active Pass'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Confirm Booking'), findsOneWidget);
      expect(find.text('Purchase Single Ticket'), findsNothing);
      expect(find.text('Go to Plans'), findsNothing);
    });

    testWidgets('5.3 no pass state shows purchase options', (tester) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_elite'),
      ))!;
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('No Active Pass'), findsOneWidget);
      expect(find.text('Purchase Single Ticket'), findsOneWidget);
      expect(find.text('Go to Plans'), findsOneWidget);
    });

    testWidgets('5.4 confirm action creates booking', (tester) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_reyu'),
      ))!;
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Booking'));
      await tester.pump(const Duration(milliseconds: 1500));

      expect(harness.bookingViewModel.activeBooking, isNotNull);
      expect(harness.bookingViewModel.flowStatus, BookingFlowStatus.booked);
    });

    testWidgets('5.4 single ticket action succeeds for user without pass', (
      tester,
    ) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_elite'),
      ))!;
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.build());
      await tester.pump(const Duration(milliseconds: 300));
      await _waitForButtonEnabled(
        tester,
        find.widgetWithText(ElevatedButton, 'Purchase Single Ticket'),
      );

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Purchase Single Ticket'),
      );
      await tester.pump(const Duration(milliseconds: 2500));

      final hasPassAfterTicket =
          (await tester.runAsync(
            () => harness.passRepository.hasActivePass('user_elite'),
          )) ??
          false;

      expect(harness.bookingViewModel.activeBooking, isNotNull);
      expect(harness.bookingViewModel.flowStatus, BookingFlowStatus.booked);
      expect(hasPassAfterTicket, isTrue);
    });

    testWidgets('5.6 renders plans screen when Go to Plans tapped', (
      tester,
    ) async {
      final harness = (await tester.runAsync(
        () => _Harness.create(userId: 'user_elite'),
      ))!;
      addTearDown(harness.dispose);

      final navigationState = NavigationState();

      await tester.pumpWidget(
        harness.build(includeNavigationState: true, navigationState: navigationState),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await _waitForButtonEnabled(
        tester,
        find.widgetWithText(OutlinedButton, 'Go to Plans'),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Go to Plans'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(navigationState.currentTabIndex, 2);
    });

    testWidgets('5.7 Property 14: displays selected station and bike', (
      tester,
    ) async {
      final combos = <({String stationName, String bikeId, int slot})>[
        (stationName: 'Station One', bikeId: 'B1', slot: 1),
        (stationName: 'Station Two', bikeId: 'B2', slot: 10),
        (stationName: 'Station Three', bikeId: 'B3', slot: 20),
      ];

      for (final combo in combos) {
        final harness = (await tester.runAsync(
          () => _Harness.create(
            userId: 'user_reyu',
            stationNameOverride: combo.stationName,
            bikeIdOverride: combo.bikeId,
            slotNumberOverride: combo.slot,
          ),
        ))!;
        addTearDown(harness.dispose);

        await tester.pumpWidget(harness.build());
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Station: ${combo.stationName}'), findsOneWidget);
        expect(find.text('Bike: #${combo.bikeId}'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });

    testWidgets('5.8 Property 16: active pass users see confirm button', (
      tester,
    ) async {
      const usersWithPass = ['user_reyu', 'user_vip'];

      for (final userId in usersWithPass) {
        final harness = (await tester.runAsync(
          () => _Harness.create(
            userId: userId,
            addPassIfNeeded: userId == 'user_vip',
          ),
        ))!;
        addTearDown(harness.dispose);

        await tester.pumpWidget(harness.build());
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.widgetWithText(ElevatedButton, 'Confirm Booking'), findsOneWidget);
        expect(find.text('Purchase Single Ticket'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });

    testWidgets('5.9 Property 17: no pass users see purchase options', (
      tester,
    ) async {
      const usersWithoutPass = ['user_elite', 'user_somnang'];

      for (final userId in usersWithoutPass) {
        final harness =
            (await tester.runAsync(() => _Harness.create(userId: userId)))!;
        addTearDown(harness.dispose);

        await tester.pumpWidget(harness.build());
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Purchase Single Ticket'), findsOneWidget);
        expect(find.text('Go to Plans'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });
  });
}

class _Harness {
  _Harness({
    required this.store,
    required this.passRepository,
    required this.bookingViewModel,
    required this.passViewModel,
    required this.station,
    required this.bike,
  });

  final MockDataStore store;
  final MockPassRepository passRepository;
  final BookingViewModel bookingViewModel;
  final PassViewModel passViewModel;
  final Station station;
  final Bike bike;

  static Future<_Harness> create({
    required String userId,
    BikeStatus bikeStatus = BikeStatus.available,
    bool addPassIfNeeded = false,
    String? stationNameOverride,
    String? bikeIdOverride,
    int? slotNumberOverride,
  }) async {
    final store = MockDataStore();

    if (addPassIfNeeded) {
      final now = DateTime.now();
      store.passes.add(
        Pass(
          id: 'pass_$userId',
          userId: userId,
          type: PassType.day,
          startDate: now,
          expiryDate: now.add(const Duration(days: 1)),
          isActive: true,
          price: PassType.day.price,
          ridesUsed: 0,
          createdAt: now,
        ),
      );
    }

    final passRepository = MockPassRepository(store);
    final bookingRepository = MockBookingRepository(store);
    final bikeRepository = MockBikeRepository(store);
    final stationRepository = MockStationRepository(store);

    final bookingViewModel = BookingViewModel(
      bookingRepository,
      passRepository,
      bikeRepository,
      stationRepository,
    );
    final passViewModel = PassViewModel(passRepository, MockUserRepository(store));

    await bookingViewModel.initialize(userId: userId);
    await passViewModel.initialize(userId: userId);

    final stationIndex = store.stations.indexWhere(
      (item) => item.id == 'station_terminal',
    );
    final baseStation = store.stations[stationIndex];
    final station = baseStation.copyWith(name: stationNameOverride ?? baseStation.name);

    final bikeIndex = store.bikes.indexWhere(
      (item) => item.stationId == station.id && item.slotNumber == 1,
    );
    store.bikes[bikeIndex] = store.bikes[bikeIndex].copyWith(
      id: bikeIdOverride ?? store.bikes[bikeIndex].id,
      slotNumber: slotNumberOverride ?? 1,
      status: bikeStatus,
    );
    store.syncStationAvailability(station.id);

    return _Harness(
      store: store,
      passRepository: passRepository,
      bookingViewModel: bookingViewModel,
      passViewModel: passViewModel,
      station: station,
      bike: store.bikes[bikeIndex],
    );
  }

  Widget build({
    bool includeNavigationState = false,
    NavigationState? navigationState,
  }) {
    Widget child = MultiProvider(
      providers: [
        ChangeNotifierProvider<BookingViewModel>.value(value: bookingViewModel),
        ChangeNotifierProvider<PassViewModel>.value(value: passViewModel),
      ],
      child: BookingConfirmationScreen(station: station, bike: bike),
    );

    if (includeNavigationState) {
      child = ChangeNotifierProvider<NavigationState>.value(
        value: navigationState ?? NavigationState(),
        child: child,
      );
    }

    return MaterialApp(home: child);
  }

  void dispose() {
    bookingViewModel.dispose();
    passViewModel.dispose();
  }
}

Future<void> _waitForButtonEnabled(
  WidgetTester tester,
  Finder buttonFinder,
) async {
  for (var i = 0; i < 15; i++) {
    if (buttonFinder.evaluate().isNotEmpty) {
      final widget = tester.widget(buttonFinder);
      if (widget is OutlinedButton && widget.onPressed != null) {
        return;
      }
      if (widget is ElevatedButton && widget.onPressed != null) {
        return;
      }
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
}
