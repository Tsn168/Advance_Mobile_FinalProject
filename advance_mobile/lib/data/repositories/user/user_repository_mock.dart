import '../../../config/app_constants.dart';
import '../../../model/user/user.dart';
import 'user_repository.dart';
import '../mock_data_store.dart';

class MockUserRepository implements IUserRepository {
  MockUserRepository(this._store);

  final MockDataStore _store;

  @override
  Future<User> createUser(User user) async {
    await _store.simulateNetworkDelay();

    final created = user.copyWith(
      id: user.id.isEmpty ? _store.nextId('user') : user.id,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );

    _store.users.add(created);
    _store.notifyChanged();
    return created;
  }

  @override
  Future<User?> getCurrentUser() async {
    return getUserById(AppConstants.defaultUserId);
  }

  @override
  Future<User?> getUserById(String userId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.users.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateActivePassId(String userId, String? activePassId) async {
    await _store.simulateNetworkDelay();

    final index = _store.users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      throw Exception('User not found: $userId');
    }

    _store.users[index] = _store.users[index].copyWith(
      activePassId: activePassId,
      updatedAt: DateTime.now(),
    );
    _store.notifyChanged();
  }

  @override
  Future<void> updateUser(User user) async {
    await _store.simulateNetworkDelay();

    final index = _store.users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      throw Exception('User not found: ${user.id}');
    }

    _store.users[index] = user.copyWith(updatedAt: DateTime.now());
    _store.notifyChanged();
  }

  @override
  Stream<User?> watchCurrentUser() {
    return watchUser(AppConstants.defaultUserId);
  }

  @override
  Stream<User?> watchUser(String userId) async* {
    yield await getUserById(userId);
    await for (final _ in _store.changes) {
      yield await getUserById(userId);
    }
  }
}
