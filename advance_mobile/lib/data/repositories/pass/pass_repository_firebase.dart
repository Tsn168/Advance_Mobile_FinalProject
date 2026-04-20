import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../config/firebase_config.dart';
import '../../../model/pass/pass.dart';
import '../../dtos/pass_dto.dart';
import 'pass_repository.dart';

class PassRepositoryFirebase implements IPassRepository {
  PassRepositoryFirebase({FirebaseDatabase? database})
    : _database =
          database ?? FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: FirebaseConfig.realtimeDatabaseUrl);

  final FirebaseDatabase _database;

  DatabaseReference get _passesRef => _database.ref(FirebaseConfig.passesPath);

  @override
  Future<Pass> createPass(Pass pass) async {
    final key = pass.id.isEmpty
        ? _passesRef.push().key
        : pass.id;
    if (key == null || key.isEmpty) {
      throw Exception('Unable to generate pass ID');
    }

    final passWithId = pass.copyWith(id: key);
    final dto = PassDTO.fromModel(passWithId);
    await _passesRef
        .child(key)
        .set(dto.toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);
    return dto.toModel();
  }

  @override
  Future<void> deletePass(String passId) async {
    await _passesRef.child(passId).remove().timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Future<List<Pass>> getAllAvailablePasses() async {
    final now = DateTime.now().toUtc();
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
        .toList(growable: false);
  }

  @override
  Future<Pass?> getActivePass(String userId) async {
    final passes = await getPassesByUserId(userId);
    final now = DateTime.now().toUtc();

    final active = passes.where((pass) {
      return pass.isActive && pass.expiryDate.toUtc().isAfter(now);
    }).toList();
    if (active.isEmpty) {
      return null;
    }

    active.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return active.first;
  }

  @override
  Future<Pass?> getPassById(String passId) async {
    final event = await _passesRef
        .child(passId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(event.value as Map);
    map.putIfAbsent('id', () => passId);
    return PassDTO.fromFirebase(map).toModel();
  }

  @override
  Future<List<Pass>> getPassesByUserId(String userId) async {
    final event = await _passesRef.get().timeout(FirebaseConfig.defaultTimeout);
    if (!event.exists || event.value == null) {
      return <Pass>[];
    }

    final root = Map<String, dynamic>.from(event.value as Map);
    final passes = <Pass>[];
    root.forEach((key, value) {
      final map = Map<String, dynamic>.from(value as Map);
      map.putIfAbsent('id', () => key);
      final pass = PassDTO.fromFirebase(map).toModel();
      if (pass.userId == userId) {
        passes.add(pass);
      }
    });

    passes.sort((a, b) => b.startDate.compareTo(a.startDate));
    return passes;
  }

  @override
  Future<bool> hasActivePass(String userId) async {
    final active = await getActivePass(userId);
    return active != null && active.isActive && !active.isExpired;
  }

  @override
  Future<void> updatePass(Pass pass) async {
    final dto = PassDTO.fromModel(pass);
    await _passesRef
        .child(pass.id)
        .update(dto.toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Stream<Pass?> watchActivePass(String userId) {
    return _passesRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return null;
      }

      final root = Map<String, dynamic>.from(value as Map);
      final now = DateTime.now().toUtc();
      final active = <Pass>[];
      root.forEach((key, raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.putIfAbsent('id', () => key);
        final pass = PassDTO.fromFirebase(map).toModel();
        if (pass.userId == userId && pass.isActive && pass.expiryDate.toUtc().isAfter(now)) {
          active.add(pass);
        }
      });

      if (active.isEmpty) {
        return null;
      }
      active.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      return active.first;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchActivePass($userId) error: $error');
    });
  }
}
