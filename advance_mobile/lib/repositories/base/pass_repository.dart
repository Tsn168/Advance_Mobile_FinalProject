import '../../models/pass.dart';

/// Abstract Pass Repository Interface
/// Both mock and real repositories implement this
abstract class IPassRepository {
  /// Get all passes for a user
  Future<List<Pass>> getPassesByUserId(String userId);

  /// Get active pass for a user
  Future<Pass?> getActivePass(String userId);

  /// Get pass by ID
  Future<Pass?> getPassById(String passId);

  /// Create a new pass
  Future<Pass> createPass(Pass pass);

  /// Update an existing pass
  Future<void> updatePass(Pass pass);

  /// Delete a pass
  Future<void> deletePass(String passId);

  /// Get all available passes (for purchase)
  Future<List<Pass>> getAllAvailablePasses();

  /// Stream of active pass for a user
  Stream<Pass?> watchActivePass(String userId);

  /// Check if user has active pass
  Future<bool> hasActivePass(String userId);
}
