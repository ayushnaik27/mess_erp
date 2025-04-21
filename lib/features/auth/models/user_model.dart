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
  final String? hostel;

  @HiveField(5)
  final String rollNumber;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final Map<String, dynamic>? additionalInfo;

  @HiveField(8)
  final DateTime lastUpdated;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.hostel,
    required this.rollNumber,
    this.phoneNumber,
    this.additionalInfo,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      hostel: data['hostel'] ?? '',
      rollNumber: data['rollNumber'] ?? id,
      phoneNumber: data['phoneNumber'],
      additionalInfo: data['additionalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'hostel': hostel,
      'rollNumber': rollNumber,
      'phoneNumber': phoneNumber,
      'additionalInfo': additionalInfo,
      'lastUpdated': DateTime.now(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? role,
    String? hostel,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hostel: hostel ?? this.hostel,
      rollNumber: this.rollNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      lastUpdated: DateTime.now(),
    );
  }
}
