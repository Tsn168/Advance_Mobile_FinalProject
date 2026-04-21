import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/booking/booking.dart';
import 'package:advance_mobile/ui/screens/home/view_model/booking_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingViewModel', () {
    late MockDataStore store;
    late MockBookingRepository bookingRepository;
    late MockPassRepository passRepository;
    late MockBikeRepository bikeRepository;
    late MockStationRepository stationRepository;
    late BookingViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      bookingRepository = MockBookingRepository(store);
      passRepository = MockPassRepository(store);
      bikeRepository = MockBikeRepository(store);
      stationRepository = MockStationRepository(store);
      viewModel = BookingViewModel(
        bookingRepository,
        passRepository,
        bikeRepository: bikeRepository,
        stationRepository: stationRepository,
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

        final scenarioViewModel = BookingViewModel(bookingRepository, passRepository);
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

    test('13.2 handles bike race condition and returns specific error', () async {
      await viewModel.initialize();
      await viewModel.prepareBooking(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      final bikeIndex = store.bikes.indexWhere((bike) => bike.id == 'bike_c1');
      store.bikes[bikeIndex] = store.bikes[bikeIndex].copyWith(
        status: BikeStatus.booked,
      );

      final success = await viewModel.confirmBooking();

      expect(success, isFalse);
      expect(viewModel.flowStatus, BookingFlowStatus.failed);
      expect(viewModel.errorMessage, contains('no longer available'));
    });

    test('13.2 handles repository booking errors', () async {
      final failingViewModel = BookingViewModel(
        _FailingBookingRepository(store),
        passRepository,
        bikeRepository: bikeRepository,
        stationRepository: stationRepository,
      );
      addTearDown(failingViewModel.dispose);

      await failingViewModel.initialize();
      await failingViewModel.prepareBooking(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      final success = await failingViewModel.confirmBooking();

      expect(success, isFalse);
      expect(failingViewModel.flowStatus, BookingFlowStatus.failed);
      expect(failingViewModel.errorMessage, contains('Network failure'));
    });
  });
}

class _FailingBookingRepository extends MockBookingRepository {
  _FailingBookingRepository(MockDataStore store) : super(store);

  @override
  Future<Booking> createBooking(Booking booking) {
    throw Exception('Network failure while creating booking');
  }
}
