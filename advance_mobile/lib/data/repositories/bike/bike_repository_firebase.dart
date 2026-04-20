import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/bike/bike.dart';
import '../../dtos/bike_dto.dart';
import 'bike_repository.dart';
import '../../../config/firebase_config.dart';

/// Real Firebase implementation of the Bike Repository.
class BikeRepositoryFirebase implements IBikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _bikesCollection =>
      _firestore.collection(FirebaseConfig.bikesCollection);

  @override
  Future<List<Bike>> getBikesByStation(String stationId) async {
    final snapshot = await _bikesCollection
        .where('stationId', isEqualTo: stationId)
        .orderBy('slotNumber')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BikeDTO.fromFirebase(data).toModel();
    }).toList();
  }

  @override
  Future<List<Bike>> getAvailableBikesByStation(String stationId) async {
    final snapshot = await _bikesCollection
        .where('stationId', isEqualTo: stationId)
        .where('status', isEqualTo: 'AVAILABLE')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BikeDTO.fromFirebase(data).toModel();
    }).toList();
  }

  @override
  Future<Bike?> getBikeById(String bikeId) async {
    final doc = await _bikesCollection.doc(bikeId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return BikeDTO.fromFirebase(data).toModel();
  }

  @override
  Future<void> updateBikeStatus(String bikeId, BikeStatus status) async {
    await _bikesCollection.doc(bikeId).update({
      'status': status.name.toUpperCase(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateBikeCondition(String bikeId, BikeCondition condition) async {
    await _bikesCollection.doc(bikeId).update({
      'condition': condition.name.toUpperCase(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Bike> createBike(Bike bike) async {
    final docRef = _bikesCollection.doc();
    final bikeWithId = bike.copyWith(id: docRef.id);
    final dto = BikeDTO.fromModel(bikeWithId);
    
    await docRef.set(dto.toFirebase());
    return bikeWithId;
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    await _bikesCollection.doc(bikeId).delete();
  }

  @override
  Stream<List<Bike>> watchBikesByStation(String stationId) {
    return _bikesCollection
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BikeDTO.fromFirebase(data).toModel();
      }).toList();
    });
  }

  @override
  Stream<Bike?> watchBike(String bikeId) {
    return _bikesCollection.doc(bikeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return BikeDTO.fromFirebase(data).toModel();
    });
  }

  @override
  Future<List<Bike>> getBikesByStatus(BikeStatus status) async {
    final snapshot = await _bikesCollection
        .where('status', isEqualTo: status.name.toUpperCase())
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BikeDTO.fromFirebase(data).toModel();
    }).toList();
  }
}
