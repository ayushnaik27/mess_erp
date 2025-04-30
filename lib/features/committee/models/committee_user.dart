import 'package:mess_erp/core/enums/user_role.dart';

class CommitteeUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final UserRole role;
  final String email;
  final String hostelId;

  CommitteeUser({
    this.id = '',
    required this.name,
    required this.username,
    required this.password,
    required String role,
    required this.email,
    required this.hostelId,
  }) : role = role == UserRole.committee.value
            ? UserRole.committee
            : UserRole.fromString(role);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'role': role.value,
      'email': email,
      'hostelId': hostelId,
    };
  }

  factory CommitteeUser.fromJson(Map<String, dynamic> json) {
    return CommitteeUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? UserRole.committee.value,
      email: json['email'] ?? '',
      hostelId: json['hostelId'] ?? '',
    );
  }

  CommitteeUser copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    UserRole? role,
    String? email,
    String? hostelId,
  }) {
    return CommitteeUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role?.value ?? this.role.value,
      email: email ?? this.email,
      hostelId: hostelId ?? this.hostelId,
    );
  }
}
