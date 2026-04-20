import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/pass/pass.dart';
import '../../dtos/pass_dto.dart';
import 'pass_repository.dart';
import '../../../config/firebase_config.dart';

/// Real Firebase implementation of the Pass Repository.
class PassRepositoryFirebase implements IPassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _passesCollection =>
      _firestore.collection(FirebaseConfig.passesCollection);

  @override
  Future<List<Pass>> getPassesByUserId(String userId) async {
    final snapshot = await _passesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PassDTO.fromFirebase(data).toModel();
    }).toList();
  }

  @override
  Future<Pass?> getActivePass(String userId) async {
    final snapshot = await _passesCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return PassDTO.fromFirebase(data).toModel();
  }

  @override
  Future<Pass?> getPassById(String passId) async {
    final doc = await _passesCollection.doc(passId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return PassDTO.fromFirebase(data).toModel();
  }

  @override
  Future<Pass> createPass(Pass pass) async {
    final docRef = _passesCollection.doc();
    final passWithId = pass.copyWith(id: docRef.id);
    final dto = PassDTO.fromModel(passWithId);

    await docRef.set(dto.toFirebase());
    return passWithId;
  }

  @override
  Future<void> updatePass(Pass pass) async {
    final dto = PassDTO.fromModel(pass);
    await _passesCollection.doc(pass.id).update(dto.toFirebase());
  }

  @override
  Future<void> deletePass(String passId) async {
    await _passesCollection.doc(passId).delete();
  }

  @override
  Future<List<Pass>> getAllAvailablePasses() async {
    return PassType.values
        .map(
          (type) => Pass(
            id: type.name,
            userId: '',
            type: type,
            startDate: DateTime.now(),
            expiryDate: DateTime.now().add(Duration(days: type.durationDays)),
            isActive: true,
            price: type.price,
          ),
        )
        .toList();
  }

  @override
  Stream<Pass?> watchActivePass(String userId) {
    return _passesCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return PassDTO.fromFirebase(data).toModel();
    });
  }

  @override
  Future<bool> hasActivePass(String userId) async {
    final activePass = await getActivePass(userId);
    return activePass != null && !activePass.isExpired;
  }
}
