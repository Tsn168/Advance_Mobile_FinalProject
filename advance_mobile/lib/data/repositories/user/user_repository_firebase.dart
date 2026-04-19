import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../../model/user/user.dart';
import '../../dtos/user_dto.dart';
import '../../repositories/user/user_repository.dart';
import '../../../config/firebase_config.dart';

/// Real Firebase implementation of the User Repository.
class UserRepositoryFirebase implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  CollectionReference get _usersCollection =>
      _firestore.collection(FirebaseConfig.usersCollection);

  @override
  Future<User?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return UserDTO.fromFirebase(data).toModel();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return getUserById(firebaseUser.uid);
  }

  @override
  Future<User> createUser(User user) async {
    final dto = UserDTO.fromModel(user);
    await _usersCollection.doc(user.id).set(dto.toFirebase());
    return user;
  }

  @override
  Future<void> updateUser(User user) async {
    final dto = UserDTO.fromModel(user);
    await _usersCollection.doc(user.id).update(dto.toFirebase());
  }

  @override
  Future<void> updateActivePassId(String userId, String? activePassId) async {
    await _usersCollection.doc(userId).update({
      'activePassId': activePassId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<User?> watchUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return UserDTO.fromFirebase(data).toModel();
    });
  }

  @override
  Stream<User?> watchCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return Stream.value(null);
    return watchUser(firebaseUser.uid);
  }
}
