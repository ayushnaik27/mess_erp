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
  static const String extraItems = 'extraItems';
  static const String hostels = 'hostels';
  static const String vendors = 'vendors';

  // Documents
  static const String roles = 'roles';

  static const String stockCategories = 'stock_categories';
  static const String transactions = 'transactions';
  static const String budgets = 'budgets';

  // Storage paths
  static const String storageTenders = 'tenders';
  static const String storageProfiles = 'profiles';

  // Subcollections
  static const String student = 'student';
  static const String clerk = 'clerk';
  static const String manager = 'manager';
  static const String muneem = 'muneem';
  static const String committee = 'committee';

  // Hostel subcollections
  static const String hostelInfo = 'info';
  static const String hostelStudents = 'students';
  static const String hostelStaff = 'staff';
  static const String hostelMess = 'mess';

  // Mess subcollections
  static const String messGrievances = 'grievances';
  static const String messBills = 'bills';
  static const String messStock = 'stock';
  static const String messTenders = 'tenders';
  static const String messExtraItems = 'extraItems';
  static const String messMenu = 'menu';

  // Field names
  static const String password = 'password';
  static const String name = 'name';
  static const String email = 'email';
  static const String rollNumber = 'rollNumber';
  static const String timestamp = 'timestamp';

  static const String announcements = 'announcements';
  static const String meal = 'meal';

  static const String extraItemRequests = 'extraItemRequests';
  static const String extraItemAmount = 'extraItemsAmount';

  static const String stockItems = 'stock_items';

  static const Map<String, String> adminUsernames = {
    clerk: 'admin',
    manager: 'manager@gmail.com',
    muneem: 'muneem@gmail.com',
    committee: 'committee@gmail.com',
  };

  static String getRolePath(String role) => '$loginCredentials/$roles/$role';

  static String getUserDocPath(String role, String userId) =>
      '$loginCredentials/$roles/$role/$userId';

  static String getEnrollmentPath(String rollNumber) =>
      '$enrollments/$rollNumber';

  static const String newLeaveDetails = 'newLeaveDetails';
  static const String fineDetails = 'fineDetails';
  static const String paymentVouchers = 'paymentVouchers';

  static String getStudentBillsPath(String studentId) =>
      '$loginCredentials/$roles/$student/$studentId/$bills';

  static String getStudentLeavesPath(String studentId) =>
      '$loginCredentials/$roles/$student/$studentId/$newLeaveDetails';

  static const String storagePathTenders = 'tenders';
  static const String storagePathProfiles = 'profiles';

  static String getStudentFinesPath(String studentId) =>
      '$loginCredentials/$roles/$student/$studentId/$fineDetails';

  // Initial passwords for each role-hostel combination
  static const Map<String, Map<String, String>> initialPasswords = {
    // Boys Hostels
    'BH1': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH2': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH3': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH4': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH5': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH6': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'BH7': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    // Girls Hostels
    'GH1': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'GH2': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'GH3': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    'MGH': {
      'clerk': 'clerk123',
      'manager': 'manager123',
      'muneem': 'muneem123',
      'committee': 'committee123',
    },
    // Add more hostels as needed
  };

  // Helper method to get initial password
  static String getInitialPassword(String hostelId, String role) {
    if (initialPasswords.containsKey(hostelId) &&
        initialPasswords[hostelId]!.containsKey(role)) {
      return initialPasswords[hostelId]![role]!;
    }
    return ''; // Empty string if no password found
  }

  // Add these new constants
  static const String stockTransactions = 'stock_transactions';
  static const String settings = 'settings';

  // Fields - User related
  static const String role = 'role';
  static const String hostelId = 'hostelId';
  static const String username = 'username';
  static const String isFirstLogin = 'isFirstLogin';
  static const String lastLogin = 'lastLogin';
  static const String createdAt = 'createdAt';

  // Fields - Common
  static const String id = 'id';
  static const String title = 'title';
  static const String description = 'description';
  static const String status = 'status';
  static const String createdBy = 'createdBy';
  static const String updatedAt = 'updatedAt';
}
