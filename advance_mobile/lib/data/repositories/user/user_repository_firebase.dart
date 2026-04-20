import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../../config/firebase_config.dart';
import '../../../model/user/user.dart';
import '../../dtos/user_dto.dart';
import '../../repositories/user/user_repository.dart';

class UserRepositoryFirebase implements IUserRepository {
  UserRepositoryFirebase({
    FirebaseDatabase? database,
    auth.FirebaseAuth? authClient,
  }) : _database =
           database ?? FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: FirebaseConfig.realtimeDatabaseUrl),
       _auth = authClient ?? auth.FirebaseAuth.instance;

  final FirebaseDatabase _database;
  final auth.FirebaseAuth _auth;

  DatabaseReference get _usersRef => _database.ref(FirebaseConfig.usersPath);

  @override
  Future<User?> getUserById(String userId) async {
    final snapshot = await _usersRef
        .child(userId)
        .get()
        .timeout(FirebaseConfig.defaultTimeout);
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    map.putIfAbsent('id', () => userId);
    return UserDTO.fromFirebase(map).toModel();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return getUserById(firebaseUser.uid);
  }

  @override
  Future<User> createUser(User user) async {
    final key = user.id.isEmpty ? _usersRef.push().key : user.id;
    if (key == null || key.isEmpty) {
      throw Exception('Unable to generate user ID');
    }

    final dto = UserDTO.fromModel(user.copyWith(id: key));
    await _usersRef
        .child(key)
        .set(dto.toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);
    return dto.toModel();
  }

  @override
  Future<void> updateUser(User user) async {
    final dto = UserDTO.fromModel(user);
    await _usersRef
        .child(user.id)
        .update(dto.toFirebase())
        .timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Future<void> updateActivePassId(String userId, String? activePassId) async {
    await _usersRef.child(userId).update({
      'activePassId': activePassId,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }).timeout(FirebaseConfig.defaultTimeout);
  }

  @override
  Stream<User?> watchUser(String userId) {
    return _usersRef.child(userId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return null;
      }
      final map = Map<String, dynamic>.from(value as Map);
      map.putIfAbsent('id', () => userId);
      return UserDTO.fromFirebase(map).toModel();
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('watchUser($userId) error: $error');
    });
  }

  @override
  Stream<User?> watchCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return Stream<User?>.value(null);
    }
    return watchUser(firebaseUser.uid);
  }
}
