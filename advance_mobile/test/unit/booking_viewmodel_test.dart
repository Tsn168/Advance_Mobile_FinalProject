import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/ui/screens/home/view_model/booking_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingViewModel', () {
    late MockDataStore store;
    late MockBikeRepository bikeRepository;
    late MockBookingRepository bookingRepository;
    late MockPassRepository passRepository;
    late MockStationRepository stationRepository;
    late BookingViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      bikeRepository = MockBikeRepository(store);
      bookingRepository = MockBookingRepository(store);
      passRepository = MockPassRepository(store);
      stationRepository = MockStationRepository(store);
      viewModel = BookingViewModel(
        bookingRepository,
        passRepository,
        bikeRepository,
        stationRepository,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('bookBike succeeds when user has active pass', () async {
      await viewModel.initialize();

      final success = await viewModel.bookBike(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      expect(success, isTrue);
      expect(viewModel.activeBooking, isNotNull);
      expect(viewModel.flowStatus, BookingFlowStatus.booked);
    });

    test('prepareBooking with active pass sets readyToBook', () async {
      await viewModel.initialize();

      await viewModel.prepareBooking(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      expect(viewModel.selectedBikeId, 'bike_c1');
      expect(viewModel.selectedStationId, 'station_central');
      expect(viewModel.selectedSlotNumber, 1);
      expect(viewModel.flowStatus, BookingFlowStatus.readyToBook);
      expect(viewModel.errorMessage, isNull);
    });

    test('prepareBooking without active pass sets requiresPassSelection', () async {
      await viewModel.initialize(userId: 'user_elite');

      await viewModel.prepareBooking(
        bikeId: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
      );

      expect(viewModel.flowStatus, BookingFlowStatus.requiresPassSelection);
      expect(viewModel.errorMessage, contains('No active pass'));
    });

    test('confirmBooking success flow', () async {
      await viewModel.initialize();
      await viewModel.prepareBooking(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      final success = await viewModel.confirmBooking();

      expect(success, isTrue);
      expect(viewModel.flowStatus, BookingFlowStatus.booked);
      expect(viewModel.activeBooking, isNotNull);
      expect(viewModel.activeBooking?.bikeId, 'bike_c1');
    });

    test('confirmBooking fails when no bike selected', () async {
      await viewModel.initialize();

      final success = await viewModel.confirmBooking();

      expect(success, isFalse);
      expect(viewModel.flowStatus, BookingFlowStatus.failed);
      expect(viewModel.errorMessage, contains('No bike selected'));
    });

    test('purchaseSingleTicketAndBook flow succeeds for user without pass', () async {
      await viewModel.initialize(userId: 'user_elite');
      await viewModel.prepareBooking(
        bikeId: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
      );

      final success = await viewModel.purchaseSingleTicketAndBook();

      expect(success, isTrue);
      expect(viewModel.flowStatus, BookingFlowStatus.booked);
      expect(viewModel.activeBooking, isNotNull);
      expect(await passRepository.hasActivePass('user_elite'), isTrue);
    });

    test('bookBike blocks when user has no active pass', () async {
      await viewModel.initialize(userId: 'user_elite');

      final success = await viewModel.bookBike(
        bikeId: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
      );

      expect(success, isFalse);
      expect(viewModel.activeBooking, isNull);
      expect(viewModel.flowStatus, BookingFlowStatus.requiresPassSelection);
      expect(viewModel.errorMessage, contains('No active pass'));
    });

    test('Property 15: pass authorization check is performed for users', () async {
      final scenarios = <(String, bool)>[
        ('user_reyu', true),
        ('user_elite', false),
        ('user_somnang', false),
      ];

      for (final scenario in scenarios) {
        final userId = scenario.$1;
        final expectedHasPass = scenario.$2;

        final scenarioViewModel = BookingViewModel(
          bookingRepository,
          passRepository,
          bikeRepository,
          stationRepository,
        );
        addTearDown(scenarioViewModel.dispose);

        await scenarioViewModel.initialize(userId: userId);
        await scenarioViewModel.prepareBooking(
          bikeId: 'bike_t1',
          stationId: 'station_terminal',
          slotNumber: 1,
        );

        if (expectedHasPass) {
          expect(
            scenarioViewModel.flowStatus,
            BookingFlowStatus.readyToBook,
          );
        } else {
          expect(
            scenarioViewModel.flowStatus,
            BookingFlowStatus.requiresPassSelection,
          );
        }
      }
    });

    test('bookBike updates bike status to booked after booking', () async {
      await viewModel.initialize();

      final success = await viewModel.bookBike(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      expect(success, isTrue);
      final bike = await bikeRepository.getBikeById('bike_c1');
      expect(bike?.status, BikeStatus.booked);
    });

    test('bookBike decrements station availability after booking', () async {
      await viewModel.initialize();
      final before = await stationRepository.getStationById('station_central');

      final success = await viewModel.bookBike(
        bikeId: 'bike_c2',
        stationId: 'station_central',
        slotNumber: 2,
      );

      final after = await stationRepository.getStationById('station_central');
      expect(success, isTrue);
      expect(after, isNotNull);
      expect(before, isNotNull);
      expect(after!.availableBikes, before!.availableBikes - 1);
    });

    test('confirmBooking prevents concurrent booking with clear error message', () async {
      await viewModel.initialize();
      await viewModel.prepareBooking(
        bikeId: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
      );

      final bikeIndex = store.bikes.indexWhere((bike) => bike.id == 'bike_t1');
      store.bikes[bikeIndex] = store.bikes[bikeIndex].copyWith(
        status: BikeStatus.booked,
      );
      store.syncStationAvailability('station_terminal');

      final success = await viewModel.confirmBooking();

      expect(success, isFalse);
      expect(viewModel.flowStatus, BookingFlowStatus.failed);
      expect(viewModel.errorMessage, contains('no longer available'));
      expect(viewModel.errorMessage, contains('refresh the bike list'));
      expect(viewModel.errorMessage, contains('go back to station details'));
    });

    test(
      '9.6 Property 18: booking creation works for active pass and single ticket authorization',
      () async {
        // Feature: bike-rental-pass-booking, Property 18: Booking Creation with Authorization
        final activePassViewModel = BookingViewModel(
          bookingRepository,
          passRepository,
          bikeRepository,
          stationRepository,
        );
        addTearDown(activePassViewModel.dispose);

        await activePassViewModel.initialize(userId: 'user_reyu');
        final passAuthorizedSuccess = await activePassViewModel.bookBike(
          bikeId: 'bike_c2',
          stationId: 'station_central',
          slotNumber: 2,
        );

        expect(passAuthorizedSuccess, isTrue);
        expect(activePassViewModel.activeBooking, isNotNull);
        expect(activePassViewModel.activeBooking!.userId, 'user_reyu');

        final ticketStore = MockDataStore();
        final ticketBookingRepository = MockBookingRepository(ticketStore);
        final ticketPassRepository = MockPassRepository(ticketStore);
        final ticketBikeRepository = MockBikeRepository(ticketStore);
        final ticketStationRepository = MockStationRepository(ticketStore);

        final ticketAuthorizedViewModel = BookingViewModel(
          ticketBookingRepository,
          ticketPassRepository,
          ticketBikeRepository,
          ticketStationRepository,
        );
        addTearDown(ticketAuthorizedViewModel.dispose);

        await ticketAuthorizedViewModel.initialize(userId: 'user_elite');
        await ticketAuthorizedViewModel.prepareBooking(
          bikeId: 'bike_t1',
          stationId: 'station_terminal',
          slotNumber: 1,
        );
        final ticketAuthorizedSuccess =
            await ticketAuthorizedViewModel.purchaseSingleTicketAndBook();

        expect(ticketAuthorizedSuccess, isTrue);
        expect(ticketAuthorizedViewModel.activeBooking, isNotNull);
        expect(ticketAuthorizedViewModel.activeBooking!.userId, 'user_elite');
      },
    );

    test('9.7 Property 19: booking marks bikes as unavailable', () async {
      // Feature: bike-rental-pass-booking, Property 19: Bike Status Update on Booking
      final scenarios = <(String bikeId, String stationId, int slotNumber)>[
        ('bike_c1', 'station_central', 1),
        ('bike_d1', 'station_downtown', 1),
        ('bike_t1', 'station_terminal', 1),
      ];

      for (final scenario in scenarios) {
        final localStore = MockDataStore();
        final localBikeRepository = MockBikeRepository(localStore);
        final localBookingRepository = MockBookingRepository(localStore);
        final localPassRepository = MockPassRepository(localStore);
        final localStationRepository = MockStationRepository(localStore);

        final localViewModel = BookingViewModel(
          localBookingRepository,
          localPassRepository,
          localBikeRepository,
          localStationRepository,
        );
        addTearDown(localViewModel.dispose);

        await localViewModel.initialize(userId: 'user_reyu');
        final success = await localViewModel.bookBike(
          bikeId: scenario.$1,
          stationId: scenario.$2,
          slotNumber: scenario.$3,
        );

        final bike = await localBikeRepository.getBikeById(scenario.$1);
        expect(success, isTrue);
        expect(bike, isNotNull);
        expect(bike!.status, BikeStatus.booked);
      }
    });

    test('9.8 Property 20: booking decrements station availability by one', () async {
      // Feature: bike-rental-pass-booking, Property 20: Station Availability Update on Booking
      final scenarios = <(String bikeId, String stationId, int slotNumber)>[
        ('bike_c1', 'station_central', 1),
        ('bike_d1', 'station_downtown', 1),
        ('bike_t2', 'station_terminal', 2),
      ];

      for (final scenario in scenarios) {
        final localStore = MockDataStore();
        final localBikeRepository = MockBikeRepository(localStore);
        final localBookingRepository = MockBookingRepository(localStore);
        final localPassRepository = MockPassRepository(localStore);
        final localStationRepository = MockStationRepository(localStore);

        final localViewModel = BookingViewModel(
          localBookingRepository,
          localPassRepository,
          localBikeRepository,
          localStationRepository,
        );
        addTearDown(localViewModel.dispose);

        await localViewModel.initialize(userId: 'user_reyu');
        final before = await localStationRepository.getStationById(scenario.$2);
        final success = await localViewModel.bookBike(
          bikeId: scenario.$1,
          stationId: scenario.$2,
          slotNumber: scenario.$3,
        );
        final after = await localStationRepository.getStationById(scenario.$2);

        expect(success, isTrue);
        expect(before, isNotNull);
        expect(after, isNotNull);
        expect(after!.availableBikes, before!.availableBikes - 1);
      }
    });

    test('9.9 Property 21: concurrent booking prevention reports recovery guidance', () async {
      // Feature: bike-rental-pass-booking, Property 21: Concurrent Booking Prevention
      final raceScenarios = <(String bikeId, String stationId, int slotNumber)>[
        ('bike_t1', 'station_terminal', 1),
        ('bike_c1', 'station_central', 1),
      ];

      for (final scenario in raceScenarios) {
        final localStore = MockDataStore();
        final localBikeRepository = MockBikeRepository(localStore);
        final localBookingRepository = MockBookingRepository(localStore);
        final localPassRepository = MockPassRepository(localStore);
        final localStationRepository = MockStationRepository(localStore);

        final localViewModel = BookingViewModel(
          localBookingRepository,
          localPassRepository,
          localBikeRepository,
          localStationRepository,
        );
        addTearDown(localViewModel.dispose);

        await localViewModel.initialize(userId: 'user_reyu');
        await localViewModel.prepareBooking(
          bikeId: scenario.$1,
          stationId: scenario.$2,
          slotNumber: scenario.$3,
        );

        final bikeIndex = localStore.bikes.indexWhere(
          (bike) => bike.id == scenario.$1,
        );
        localStore.bikes[bikeIndex] = localStore.bikes[bikeIndex].copyWith(
          status: BikeStatus.booked,
        );
        localStore.syncStationAvailability(scenario.$2);

        final success = await localViewModel.confirmBooking();

        expect(success, isFalse);
        expect(localViewModel.errorMessage, contains('no longer available'));
        expect(localViewModel.errorMessage, contains('refresh the bike list'));
        expect(
          localViewModel.errorMessage,
          contains('go back to station details'),
        );
      }
    });

    test('completeCurrentBooking clears active booking', () async {
      await viewModel.initialize();

      final success = await viewModel.bookBike(
        bikeId: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
      );
      expect(success, isTrue);

      await viewModel.completeCurrentBooking(
        rideDistance: 3.2,
        rideDuration: 18,
      );

      expect(viewModel.activeBooking, isNull);
      expect(viewModel.flowStatus, BookingFlowStatus.idle);
    });
  });
}
