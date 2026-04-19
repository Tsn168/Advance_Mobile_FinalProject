import '../models/user.dart';

/// User DTO — handles converting User data to/from Firebase format.
/// DTO = Data Transfer Object (bridges between your app and the database).
class UserDTO {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? activePassId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserDTO({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    this.activePassId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert DTO → Model (use this when reading from Firebase)
  User toModel() {
    return User(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      activePassId: activePassId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from Model (use this when preparing to save to Firebase)
  factory UserDTO.fromModel(User user) {
    return UserDTO(
      id: user.id,
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profileImageUrl: user.profileImageUrl,
      activePassId: user.activePassId,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Create DTO from a Firebase document map
  factory UserDTO.fromFirebase(Map<String, dynamic> map) {
    return UserDTO(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      activePassId: map['activePassId'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toString()),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : null,
    );
  }

  /// Convert DTO to a Firebase-ready map (use this when saving to Firestore)
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'activePassId': activePassId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
