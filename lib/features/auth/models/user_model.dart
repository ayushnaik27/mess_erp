import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String hostelId;

  @HiveField(5)
  final String? rollNumber;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final Map<String, dynamic>? additionalInfo;

  @HiveField(9)
  final DateTime lastUpdated;

  @HiveField(10)
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.hostelId,
    this.rollNumber,
    this.phoneNumber,
    this.isActive = true,
    this.additionalInfo,
    DateTime? lastUpdated,
    DateTime? createdAt,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      hostelId: data['hostelId'],
      rollNumber: data['rollNumber'],
      phoneNumber: data['phoneNumber'],
      isActive: data['isActive'] ?? true,
      additionalInfo: data['additionalInfo'],
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as dynamic).toDate()
          : DateTime.now(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'hostelId': hostelId,
      'rollNumber': rollNumber,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'additionalInfo': additionalInfo,
      'lastUpdated': DateTime.now(),
      'createdAt': createdAt,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? role,
    String? hostelId,
    String? phoneNumber,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hostelId: hostelId ?? this.hostelId,
      rollNumber: this.rollNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: this.createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  bool canAccessHostel(String hostelId) {
    return this.hostelId == hostelId;
  }

  bool get isAdmin {
    return role != 'student';
  }

  bool get isStaff {
    return role == 'clerk' ||
        role == 'manager' ||
        role == 'muneem' ||
        role == 'committee' ||
        role == 'warden';
  }

  bool get isSuperAdmin {
    return role == 'super_admin';
  }
}
