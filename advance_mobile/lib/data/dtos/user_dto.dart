import '../../model/user/user.dart';

/// User DTO - Data Transfer Object for User
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

  factory UserDTO.fromFirebase(Map<String, dynamic> map) {
    return UserDTO(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      activePassId: map['activePassId'],
      createdAt:
          _parseDateTime(map['createdAt'])?.toUtc() ?? DateTime.now().toUtc(),
      updatedAt: _parseDateTime(map['updatedAt'])?.toUtc(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'activePassId': activePassId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
