enum UserRole {
  committee,
  student,
  admin,
  muneem,
  staff,
  manager,
  clerk;

  String get value {
    switch (this) {
      case UserRole.committee:
        return 'committee';
      case UserRole.student:
        return 'student';
      case UserRole.admin:
        return 'admin';
      case UserRole.muneem:
        return 'muneem';
      case UserRole.staff:
        return 'staff';
      case UserRole.manager:
        return 'manager';
      case UserRole.clerk:
        return 'clerk';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'committee':
        return UserRole.committee;
      case 'student':
        return UserRole.student;
      case 'admin':
        return UserRole.admin;
      case 'munim':
        return UserRole.muneem;
      case 'staff':
        return UserRole.staff;
      case 'manager':
        return UserRole.manager;
      case 'clerk':
        return UserRole.clerk;
      default:
        throw ArgumentError('Invalid role value: $value');
    }
  }
}
