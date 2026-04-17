import '../../models/bike.dart';

/// Abstract Bike Repository Interface
abstract class IBikeRepository {
  /// Get all bikes at a station
  Future<List<Bike>> getBikesByStation(String stationId);

  /// Get available bikes at a station
  Future<List<Bike>> getAvailableBikesByStation(String stationId);

  /// Get bike by ID
  Future<Bike?> getBikeById(String bikeId);

  /// Update bike status
  Future<void> updateBikeStatus(String bikeId, BikeStatus status);

  /// Update bike condition
  Future<void> updateBikeCondition(String bikeId, BikeCondition condition);

  /// Create a new bike
  Future<Bike> createBike(Bike bike);

  /// Delete a bike
  Future<void> deleteBike(String bikeId);

  /// Stream of bikes at a station with real-time updates
  Stream<List<Bike>> watchBikesByStation(String stationId);

  /// Stream of a specific bike with real-time updates
  Stream<Bike?> watchBike(String bikeId);

  /// Get bikes by status
  Future<List<Bike>> getBikesByStatus(BikeStatus status);
}
