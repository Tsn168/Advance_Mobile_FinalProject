import 'dart:async';

import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/pass/pass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Repository enhancements', () {
    late MockDataStore store;
    late MockBikeRepository bikeRepository;
    late MockPassRepository passRepository;

    setUp(() {
      store = MockDataStore();
      bikeRepository = MockBikeRepository(store);
      passRepository = MockPassRepository(store);
    });

    test(
      'watchBikesByStation emits station-filtered bikes and reflects updates',
      () async {
        final iterator = StreamIterator<List<Bike>>(
          bikeRepository.watchBikesByStation('station_central'),
        );

        expect(await iterator.moveNext(), isTrue);
        final firstEmission = iterator.current;
        expect(firstEmission, isNotEmpty);
        expect(
          firstEmission.every((bike) => bike.stationId == 'station_central'),
          isTrue,
        );
        expect(
          firstEmission.map((bike) => bike.slotNumber).toList(),
          orderedEquals([1, 2, 3]),
        );

        store.bikes.add(
          Bike(
            id: 'bike_c4',
            stationId: 'station_central',
            slotNumber: 4,
            status: BikeStatus.available,
            condition: BikeCondition.good,
            model: 'CityBike A4',
          ),
        );

        expect(await iterator.moveNext(), isTrue);
        final secondEmission = iterator.current;
        expect(
          secondEmission.map((bike) => bike.slotNumber).toList(),
          orderedEquals([1, 2, 3, 4]),
        );
        expect(
          secondEmission.every((bike) => bike.stationId == 'station_central'),
          isTrue,
        );

        await iterator.cancel();
      },
    );

    test('hasActivePass returns true for active pass', () async {
      final result = await passRepository.hasActivePass('user_reyu');
      expect(result, isTrue);
    });

    test('hasActivePass returns false for expired pass', () async {
      store.passes.add(
        Pass(
          id: 'expired_pass',
          userId: 'user_expired_only',
          type: PassType.day,
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          isActive: true,
          price: PassType.day.price,
        ),
      );

      final result = await passRepository.hasActivePass('user_expired_only');
      expect(result, isFalse);
    });

    test('hasActivePass returns false for no pass', () async {
      final result = await passRepository.hasActivePass('user_no_pass');
      expect(result, isFalse);
    });
  });
}
