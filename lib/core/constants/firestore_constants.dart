class FirestoreConstants {
  // Root collections
  static const String loginCredentials = 'loginCredentials';
  static const String enrollments = 'enrollments';
  static const String users = 'users';
  static const String bills = 'bills';
  static const String vouchers = 'vouchers';
  static const String items = 'items';
  static const String stock = 'stock';
  static const String grievances = 'grievances';
  static const String tenders = 'tenders';
  static const String extraItems = 'extra_items';

  // Documents
  static const String roles = 'roles';

  // Subcollections
  static const String student = 'student';
  static const String clerk = 'clerk';
  static const String manager = 'manager';
  static const String muneem = 'muneem';
  static const String committee = 'committee';

  // Field names
  static const String password = 'password';
  static const String name = 'name';
  static const String email = 'email';
  static const String rollNumber = 'rollNumber';
  static const String timestamp = 'timestamp';

  static const String announcements = 'announcements';
  static const String meal = 'meal';

  static const String extraItemRequests = 'extraItems_requests';
  static const String extraItemAmount = 'extraItems_amount';

  // Role-specific usernames
  static const Map<String, String> adminUsernames = {
    clerk: 'admin',
    manager: 'manager@gmail.com',
    muneem: 'muneem@gmail.com',
    committee: 'committee@gmail.com',
  };

  // Path builders
  static String getRolePath(String role) => '$loginCredentials/$roles/$role';

  static String getUserDocPath(String role, String userId) =>
      '$loginCredentials/$roles/$role/$userId';

  static String getEnrollmentPath(String rollNumber) =>
      '$enrollments/$rollNumber';
}
