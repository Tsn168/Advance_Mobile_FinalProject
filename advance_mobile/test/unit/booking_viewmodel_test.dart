import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/ui/screens/home/view_model/booking_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingViewModel', () {
    late MockDataStore store;
    late BookingViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      viewModel = BookingViewModel(
        MockBookingRepository(store),
        MockPassRepository(store),
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
