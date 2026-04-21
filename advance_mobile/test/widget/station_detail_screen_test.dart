import 'package:advance_mobile/data/repositories/bike/bike_repository.dart';
import 'package:advance_mobile/data/repositories/bike/bike_repository_mock.dart';
import 'package:advance_mobile/data/repositories/booking/booking_repository_mock.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/station/station_repository.dart';
import 'package:advance_mobile/data/repositories/station/station_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/station/station.dart';
import 'package:advance_mobile/service_locator.dart';
import 'package:advance_mobile/ui/screens/home/view_model/booking_viewmodel.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:advance_mobile/ui/screens/station_detail/station_detail_screen.dart';
import 'package:advance_mobile/ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'package:advance_mobile/ui/widgets/bike_slot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late MockDataStore store;
  late BookingViewModel bookingViewModel;
  late PassViewModel passViewModel;

  setUp(() async {
    await getIt.reset();

    store = MockDataStore();
    bookingViewModel = BookingViewModel(
      MockBookingRepository(store),
      MockPassRepository(store),
      MockBikeRepository(store),
      MockStationRepository(store),
    );
    passViewModel = PassViewModel(
      MockPassRepository(store),
      MockUserRepository(store),
    );
  });

  tearDown(() async {
    bookingViewModel.dispose();
    passViewModel.dispose();
    await getIt.reset();
  });

  group('StationDetailScreen', () {
    testWidgets('3.5 - shows loading state', (tester) async {
      final station = _buildStation(id: 'station_loading', totalSlots: 8);

      final bikeRepository = _TestBikeRepository(
        stationBikes: {
          station.id: [
            _buildBike(
              id: '009',
              stationId: station.id,
              slotNumber: 1,
              status: BikeStatus.available,
            ),
          ],
        },
        delay: const Duration(milliseconds: 500),
      );
      final stationRepository = _TestStationRepository(
        stations: {station.id: station.copyWith(availableBikes: 1)},
        delay: const Duration(milliseconds: 500),
      );

      _registerStationDetailFactory(bikeRepository, stationRepository);

      await tester.pumpWidget(
        _wrapWithProviders(
          StationDetailScreen(stationId: station.id),
          bookingViewModel,
          passViewModel,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(BikeSlotCard), findsWidgets);
    });

    testWidgets('3.5 - shows error state with retry UI', (tester) async {
      final bikeRepository = _TestBikeRepository(stationBikes: const {});
      final stationRepository = _TestStationRepository(
        stations: const {},
        getByIdError: Exception('Station fetch failed'),
      );

      _registerStationDetailFactory(bikeRepository, stationRepository);

      await tester.pumpWidget(
        _wrapWithProviders(
          const StationDetailScreen(stationId: 'station_missing'),
          bookingViewModel,
          passViewModel,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Station fetch failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      '3.5 - renders available/unavailable/empty slots correctly',
      (tester) async {
        final station = _buildStation(id: 'station_cards', totalSlots: 4);
        final bikes = [
          _buildBike(
            id: '009',
            stationId: station.id,
            slotNumber: 1,
            status: BikeStatus.available,
          ),
          _buildBike(
            id: '902',
            stationId: station.id,
            slotNumber: 2,
            status: BikeStatus.booked,
          ),
        ];

        final bikeRepository = _TestBikeRepository(
          stationBikes: {station.id: bikes},
        );
        final stationRepository = _TestStationRepository(
          stations: {
            station.id: station.copyWith(
              availableBikes: bikes.where((bike) => bike.isAvailable).length,
            ),
          },
        );

        _registerStationDetailFactory(bikeRepository, stationRepository);

        await tester.pumpWidget(
          _wrapWithProviders(
            StationDetailScreen(stationId: station.id),
            bookingViewModel,
            passViewModel,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BikeSlotCard), findsNWidgets(4));
        expect(find.text('AVAILABLE'), findsOneWidget);
        expect(find.text('UNAVAILABLE'), findsOneWidget);
        expect(find.text('EMPTY'), findsNWidgets(2));
      },
    );

    testWidgets('3.5 - selects bike and navigates to booking confirmation', (
      tester,
    ) async {
      final station = _buildStation(id: 'station_nav', totalSlots: 2);
      final bikes = [
        _buildBike(
          id: '101',
          stationId: station.id,
          slotNumber: 1,
          status: BikeStatus.available,
        ),
      ];

      final bikeRepository = _TestBikeRepository(
        stationBikes: {station.id: bikes},
      );
      final stationRepository = _TestStationRepository(
        stations: {station.id: station.copyWith(availableBikes: 1)},
      );

      _registerStationDetailFactory(bikeRepository, stationRepository);

      await tester.pumpWidget(
        _wrapWithProviders(
          StationDetailScreen(stationId: station.id),
          bookingViewModel,
          passViewModel,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('BikeID: #101'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Booking'), findsOneWidget);
      expect(find.textContaining('Station:'), findsOneWidget);
      expect(find.textContaining('Bike:'), findsOneWidget);
    });

    testWidgets(
      '3.6 Property 12 - for varying slot counts, exactly N bike slot entries are rendered',
      (tester) async {
        final binding = tester.binding;
        await binding.setSurfaceSize(const Size(1200, 12000));
        addTearDown(() => binding.setSurfaceSize(null));

        const slotCounts = [5, 11, 23, 37, 50];

        for (final totalSlots in slotCounts) {
          final stationId = 'station_slots_$totalSlots';
          final occupied = totalSlots ~/ 3;

          final bikes = <Bike>[];
          for (var i = 1; i <= occupied; i++) {
            bikes.add(
              _buildBike(
                id: '${totalSlots}_$i',
                stationId: stationId,
                slotNumber: i,
                status: i.isEven ? BikeStatus.booked : BikeStatus.available,
              ),
            );
          }

          final station = _buildStation(
            id: stationId,
            totalSlots: totalSlots,
          ).copyWith(
            availableBikes: bikes.where((bike) => bike.isAvailable).length,
          );

          final bikeRepository = _TestBikeRepository(
            stationBikes: {stationId: bikes},
          );
          final stationRepository = _TestStationRepository(
            stations: {stationId: station},
          );

          _registerStationDetailFactory(bikeRepository, stationRepository);

          await tester.pumpWidget(
            _wrapWithProviders(
              StationDetailScreen(stationId: stationId),
              bookingViewModel,
              passViewModel,
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byType(BikeSlotCard),
            findsNWidgets(totalSlots),
            reason:
                'Expected exactly $totalSlots slot cards for station $stationId',
          );

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      '3.7 Property 13 - bike slot visual distinction for available, unavailable, and empty',
      (tester) async {
        final stationId = 'station_visual';
        final station = _buildStation(id: stationId, totalSlots: 4);

        final bikes = [
          _buildBike(
            id: 'a1',
            stationId: stationId,
            slotNumber: 1,
            status: BikeStatus.available,
          ),
          _buildBike(
            id: 'u1',
            stationId: stationId,
            slotNumber: 2,
            status: BikeStatus.booked,
          ),
        ];

        final bikeRepository = _TestBikeRepository(
          stationBikes: {stationId: bikes},
        );
        final stationRepository = _TestStationRepository(
          stations: {
            stationId: station.copyWith(
              availableBikes: bikes.where((bike) => bike.isAvailable).length,
            ),
          },
        );

        _registerStationDetailFactory(bikeRepository, stationRepository);

        await tester.pumpWidget(
          _wrapWithProviders(
            StationDetailScreen(stationId: stationId),
            bookingViewModel,
            passViewModel,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('AVAILABLE'), findsOneWidget);
        expect(find.text('UNAVAILABLE'), findsOneWidget);
        expect(find.text('EMPTY'), findsNWidgets(2));
      },
    );
  });
}

void _registerStationDetailFactory(
  IBikeRepository bikeRepository,
  IStationRepository stationRepository,
) {
  if (getIt.isRegistered<StationDetailViewModel>()) {
    getIt.unregister<StationDetailViewModel>();
  }

  getIt.registerFactory<StationDetailViewModel>(
    () => StationDetailViewModel(bikeRepository, stationRepository),
  );
}

Widget _wrapWithProviders(
  Widget child,
  BookingViewModel bookingViewModel,
  PassViewModel passViewModel,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<BookingViewModel>.value(value: bookingViewModel),
      ChangeNotifierProvider<PassViewModel>.value(value: passViewModel),
    ],
    child: MaterialApp(home: child),
  );
}

Station _buildStation({required String id, required int totalSlots}) {
  return Station(
    id: id,
    name: 'Station $id',
    latitude: 11.56,
    longitude: 104.92,
    totalSlots: totalSlots,
    availableBikes: 0,
    address: 'Test Address',
  );
}

Bike _buildBike({
  required String id,
  required String stationId,
  required int slotNumber,
  required BikeStatus status,
}) {
  return Bike(
    id: id,
    stationId: stationId,
    slotNumber: slotNumber,
    status: status,
    condition: BikeCondition.good,
    model: 'Test Bike',
  );
}

class _TestStationRepository implements IStationRepository {
  _TestStationRepository({
    required this.stations,
    this.delay = Duration.zero,
    this.getByIdError,
  });

  final Map<String, Station> stations;
  final Duration delay;
  final Object? getByIdError;

  @override
  Future<Station?> getStationById(String stationId) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (getByIdError != null) {
      throw getByIdError!;
    }
    return stations[stationId];
  }

  @override
  Future<List<Station>> getAllStations() {
    throw UnimplementedError();
  }

  @override
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateStationAvailability(String stationId, int availableBikes) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Station>> watchAllStations() {
    throw UnimplementedError();
  }

  @override
  Stream<Station?> watchStation(String stationId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Station>> getStationsWithAvailableBikes() {
    throw UnimplementedError();
  }
}

class _TestBikeRepository implements IBikeRepository {
  _TestBikeRepository({
    required this.stationBikes,
    this.delay = Duration.zero,
  });

  final Map<String, List<Bike>> stationBikes;
  final Duration delay;

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final bikes = List<Bike>.from(stationBikes[stationId] ?? const []);
    bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
    return bikes;
  }

  @override
  Stream<List<Bike>> watchBikesByStation(String stationId) {
    final bikes = List<Bike>.from(stationBikes[stationId] ?? const []);
    bikes.sort((a, b) => a.slotNumber.compareTo(b.slotNumber));
    return Stream<List<Bike>>.value(bikes);
  }

  @override
  Future<List<Bike>> getAvailableBikesByStation(String stationId) {
    throw UnimplementedError();
  }

  @override
  Future<Bike?> getBikeById(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateBikeCondition(String bikeId, BikeCondition condition) {
    throw UnimplementedError();
  }

  @override
  Future<Bike> createBike(Bike bike) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBike(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Stream<Bike?> watchBike(String bikeId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Bike>> getBikesByStatus(BikeStatus status) {
    throw UnimplementedError();
  }
}
