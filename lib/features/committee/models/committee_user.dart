class CommitteeUser {
  String name;
  String username;
  String password;
  String role;
  String? email;

  CommitteeUser({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.email,
  });

  factory CommitteeUser.fromJson(Map<String, dynamic> json) {
    return CommitteeUser(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'email': email,
    };
  }
}
