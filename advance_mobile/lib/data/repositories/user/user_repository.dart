import '../../../model/user/user.dart';

/// Abstract User Repository Interface
abstract class IUserRepository {
  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Get current signed-in user
  Future<User?> getCurrentUser();

  /// Create a user
  Future<User> createUser(User user);

  /// Update existing user profile
  Future<void> updateUser(User user);

  /// Update active pass reference on user
  Future<void> updateActivePassId(String userId, String? activePassId);

  /// Stream current user updates
  Stream<User?> watchCurrentUser();

  /// Stream user updates by ID
  Stream<User?> watchUser(String userId);
}
