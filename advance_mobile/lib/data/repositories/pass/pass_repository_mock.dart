import '../../../model/pass/pass.dart';
import 'pass_repository.dart';
import '../mock_data_store.dart';

class MockPassRepository implements IPassRepository {
  MockPassRepository(this._store);

  final MockDataStore _store;

  @override
  Future<Pass> createPass(Pass pass) async {
    await _store.simulateNetworkDelay();

    final created = pass.copyWith(
      id: pass.id.isEmpty ? _store.nextId('pass') : pass.id,
      createdAt: pass.createdAt ?? DateTime.now(),
    );

    _store.passes.add(created);
    _store.notifyChanged();
    return created;
  }

  @override
  Future<void> deletePass(String passId) async {
    await _store.simulateNetworkDelay();
    _store.passes.removeWhere((pass) => pass.id == passId);
    _store.notifyChanged();
  }

  @override
  Future<List<Pass>> getAllAvailablePasses() async {
    await _store.simulateNetworkDelay();
    final now = DateTime.now();

    return PassType.values
        .map(
          (type) => Pass(
            id: 'template_${type.name}',
            userId: '',
            type: type,
            startDate: now,
            expiryDate: now.add(Duration(days: type.durationDays)),
            isActive: false,
            price: type.price,
            ridesUsed: 0,
            createdAt: now,
          ),
        )
        .toList();
  }

  @override
  Future<Pass?> getActivePass(String userId) async {
    await _store.simulateNetworkDelay();

    final now = DateTime.now();
    try {
      return _store.passes.firstWhere(
        (pass) =>
            pass.userId == userId &&
            pass.isActive &&
            pass.expiryDate.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Pass?> getPassById(String passId) async {
    await _store.simulateNetworkDelay();
    try {
      return _store.passes.firstWhere((pass) => pass.id == passId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Pass>> getPassesByUserId(String userId) async {
    await _store.simulateNetworkDelay();
    final passes = _store.passes
        .where((pass) => pass.userId == userId)
        .toList();
    passes.sort((a, b) => b.startDate.compareTo(a.startDate));
    return passes;
  }

  @override
  Future<bool> hasActivePass(String userId) async {
    await _store.simulateNetworkDelay();
    return _store.passes.any(
      (pass) => pass.userId == userId && pass.isActive && !pass.isExpired,
    );
  }

  @override
  Future<void> updatePass(Pass pass) async {
    await _store.simulateNetworkDelay();
    final index = _store.passes.indexWhere((item) => item.id == pass.id);
    if (index == -1) {
      throw Exception('Pass not found for update: ${pass.id}');
    }
    _store.passes[index] = pass;
    _store.notifyChanged();
  }

  @override
  Stream<Pass?> watchActivePass(String userId) async* {
    yield await getActivePass(userId);
    await for (final _ in _store.changes) {
      yield await getActivePass(userId);
    }
  }
}
