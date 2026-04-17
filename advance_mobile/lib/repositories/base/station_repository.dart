import '../../models/station.dart';

/// Abstract Station Repository Interface
abstract class IStationRepository {
  /// Get all stations
  Future<List<Station>> getAllStations();

  /// Get station by ID
  Future<Station?> getStationById(String stationId);

  /// Get nearby stations (within a certain radius)
  Future<List<Station>> getNearbyStations(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  });

  /// Update station with available bikes count
  Future<void> updateStationAvailability(String stationId, int availableBikes);

  /// Stream of all stations with real-time updates
  Stream<List<Station>> watchAllStations();

  /// Stream of a specific station with real-time updates
  Stream<Station?> watchStation(String stationId);

  /// Get stations with available bikes
  Future<List<Station>> getStationsWithAvailableBikes();
}
