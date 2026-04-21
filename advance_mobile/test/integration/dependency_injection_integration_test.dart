import 'package:advance_mobile/data/repositories/bike/bike_repository.dart';
import 'package:advance_mobile/data/repositories/station/station_repository.dart';
import 'package:advance_mobile/service_locator.dart';
import 'package:advance_mobile/ui/screens/map/view_model/booking_viewmodel.dart';
import 'package:advance_mobile/ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('10.3 Dependency injection integration', () {
    setUp(() async {
      await getIt.reset();
      await setupServiceLocator();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('StationDetailViewModel resolves from GetIt with dependencies', () {
      final vm = getIt<StationDetailViewModel>();

      expect(vm, isNotNull);
      expect(getIt.isRegistered<IBikeRepository>(), isTrue);
      expect(getIt.isRegistered<IStationRepository>(), isTrue);

      vm.dispose();
    });

    test('BookingViewModel resolves and can run lifecycle', () async {
      final vm = getIt<BookingViewModel>();

      await vm.initialize();
      await vm.prepareBooking(
        bikeId: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
      );

      expect(vm.selectedBikeId, 'bike_c1');
      expect(vm.selectedStationId, 'station_central');

      vm.dispose();
    });
  });
}
