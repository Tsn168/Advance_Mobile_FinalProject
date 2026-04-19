import 'dart:async';

import '../../config/app_constants.dart';
import '../../model/bike/bike.dart';
import '../../model/booking/booking.dart';
import '../../model/pass/pass.dart';
import '../../model/station/station.dart';
import '../../model/user/user.dart';

/// Shared in-memory data store for all mock repositories.
class MockDataStore {
  MockDataStore() {
    _seedData();
  }

  final List<User> users = [];
  final List<Pass> passes = [];
  final List<Station> stations = [];
  final List<Bike> bikes = [];
  final List<Booking> bookings = [];

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  int _idCounter = 1000;

  Stream<void> get changes => _changesController.stream;

  Future<void> simulateNetworkDelay() {
    return Future.delayed(AppConstants.mockNetworkDelay);
  }

  String nextId(String prefix) {
    _idCounter += 1;
    return '${prefix}_$_idCounter';
  }

  void notifyChanged() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  void syncStationAvailability(String stationId) {
    final stationIndex = stations.indexWhere(
      (station) => station.id == stationId,
    );
    if (stationIndex == -1) {
      return;
    }

    final availableCount = bikes.where((bike) {
      return bike.stationId == stationId && bike.status == BikeStatus.available;
    }).length;

    stations[stationIndex] = stations[stationIndex].copyWith(
      availableBikes: availableCount,
      lastUpdated: DateTime.now(),
    );
  }

  void syncAllStationAvailability() {
    for (final station in stations) {
      syncStationAvailability(station.id);
    }
  }

  void _seedData() {
    final now = DateTime.now();

    users.addAll([
      User(
        id: AppConstants.defaultUserId,
        email: 'reyu@bikeshare.com',
        name: 'Reyu',
        activePassId: 'pass_monthly_reyu',
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      User(
        id: 'user_elite',
        email: 'elite@bikeshare.com',
        name: 'Elite',
        activePassId: null,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      User(
        id: 'user_somnang',
        email: 'somnang@bikeshare.com',
        name: 'Somnang',
        activePassId: null,
        createdAt: now.subtract(const Duration(days: 150)),
      ),
    ]);

    passes.addAll([
      Pass(
        id: 'pass_monthly_reyu',
        userId: AppConstants.defaultUserId,
        type: PassType.monthly,
        startDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 27)),
        isActive: true,
        price: PassType.monthly.price,
        ridesUsed: 12,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Pass(
        id: 'pass_old_somnang',
        userId: 'user_somnang',
        type: PassType.day,
        startDate: now.subtract(const Duration(days: 35)),
        expiryDate: now.subtract(const Duration(days: 34)),
        isActive: false,
        price: PassType.day.price,
        ridesUsed: 2,
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ]);

    stations.addAll([
      Station(
        id: 'station_central',
        name: 'Central Station',
        latitude: 11.5564,
        longitude: 104.9282,
        totalSlots: 20,
        availableBikes: 0,
        address: 'Central District',
        lastUpdated: now,
      ),
      Station(
        id: 'station_downtown',
        name: 'Downtown Hub',
        latitude: 11.5625,
        longitude: 104.916,
        totalSlots: 15,
        availableBikes: 0,
        address: 'Downtown Avenue',
        lastUpdated: now,
      ),
      Station(
        id: 'station_park',
        name: 'Park Station',
        latitude: 11.545,
        longitude: 104.94,
        totalSlots: 18,
        availableBikes: 0,
        address: 'City Park',
        lastUpdated: now,
      ),
      Station(
        id: 'station_terminal',
        name: 'Terminal Station',
        latitude: 11.57,
        longitude: 104.901,
        totalSlots: 22,
        availableBikes: 0,
        address: 'Transit Terminal',
        lastUpdated: now,
      ),
    ]);

    bikes.addAll([
      Bike(
        id: 'bike_c1',
        stationId: 'station_central',
        slotNumber: 1,
        status: BikeStatus.available,
        condition: BikeCondition.excellent,
        model: 'CityBike A1',
        color: 'Blue',
        kmsRidden: 120,
        lastServiced: now.subtract(const Duration(days: 8)),
      ),
      Bike(
        id: 'bike_c2',
        stationId: 'station_central',
        slotNumber: 2,
        status: BikeStatus.available,
        condition: BikeCondition.good,
        model: 'CityBike A2',
        color: 'White',
        kmsRidden: 210,
        lastServiced: now.subtract(const Duration(days: 14)),
      ),
      Bike(
        id: 'bike_c3',
        stationId: 'station_central',
        slotNumber: 3,
        status: BikeStatus.maintenance,
        condition: BikeCondition.fair,
        model: 'CityBike A3',
        color: 'Red',
        kmsRidden: 450,
        lastServiced: now.subtract(const Duration(days: 28)),
      ),
      Bike(
        id: 'bike_d1',
        stationId: 'station_downtown',
        slotNumber: 1,
        status: BikeStatus.available,
        condition: BikeCondition.excellent,
        model: 'MetroBike D1',
        color: 'Black',
        kmsRidden: 85,
        lastServiced: now.subtract(const Duration(days: 6)),
      ),
      Bike(
        id: 'bike_d2',
        stationId: 'station_downtown',
        slotNumber: 2,
        status: BikeStatus.booked,
        condition: BikeCondition.good,
        model: 'MetroBike D2',
        color: 'Green',
        kmsRidden: 178,
        lastServiced: now.subtract(const Duration(days: 10)),
      ),
      Bike(
        id: 'bike_p1',
        stationId: 'station_park',
        slotNumber: 1,
        status: BikeStatus.available,
        condition: BikeCondition.good,
        model: 'ParkBike P1',
        color: 'Blue',
        kmsRidden: 165,
        lastServiced: now.subtract(const Duration(days: 18)),
      ),
      Bike(
        id: 'bike_t1',
        stationId: 'station_terminal',
        slotNumber: 1,
        status: BikeStatus.available,
        condition: BikeCondition.excellent,
        model: 'TerminalBike T1',
        color: 'Silver',
        kmsRidden: 102,
        lastServiced: now.subtract(const Duration(days: 4)),
      ),
      Bike(
        id: 'bike_t2',
        stationId: 'station_terminal',
        slotNumber: 2,
        status: BikeStatus.available,
        condition: BikeCondition.good,
        model: 'TerminalBike T2',
        color: 'Black',
        kmsRidden: 132,
        lastServiced: now.subtract(const Duration(days: 12)),
      ),
    ]);

    bookings.add(
      Booking(
        id: 'booking_history_1',
        userId: AppConstants.defaultUserId,
        bikeId: 'bike_d2',
        stationId: 'station_downtown',
        slotNumber: 2,
        bookingDate: now.subtract(const Duration(days: 8, hours: 3)),
        pickupDate: now.subtract(
          const Duration(days: 8, hours: 2, minutes: 45),
        ),
        returnDate: now.subtract(const Duration(days: 8, hours: 2)),
        status: BookingStatus.completed,
        rideDistance: 7.8,
        rideDuration: 45,
      ),
    );

    syncAllStationAvailability();
  }
}
