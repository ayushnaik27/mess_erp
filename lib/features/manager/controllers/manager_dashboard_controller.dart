import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class ManagerDashboardController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _authService;

  // Observable properties
  final RxBool isLoading = true.obs;
  final RxString hostelId = ''.obs;
  final RxString hostelName = ''.obs;
  final RxInt totalGrievances = 0.obs;
  final RxInt pendingVouchers = 0.obs;
  final RxInt stockItems = 0.obs;
  final RxDouble stockValue = 0.0.obs;

  // Financial data
  final RxDouble totalBudget = 0.0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble billsCollected = 0.0.obs;
  final RxDouble billsPending = 0.0.obs;
  final RxDouble savings = 0.0.obs;

  // Recent transactions
  final RxList<Map<String, dynamic>> recentTransactions =
      <Map<String, dynamic>>[].obs;

  // Inventory categories
  final RxList<Map<String, dynamic>> inventoryCategories =
      <Map<String, dynamic>>[].obs;

  // User information
  Rx<User?> currentUser = Rx<User?>(null);

  // Constructor with dependency injection
  ManagerDashboardController({required AuthPersistenceService authService})
      : _authService = authService;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    loadDashboardData();
  }

  // Initialize user information
  Future<void> _initializeUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        hostelId.value = user.hostelId;
        _loadHostelInfo();
      } else {
        _logger.e('No authenticated user found');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _logger.e('Error initializing user', error: e);
    }
  }

  // Load hostel information
  Future<void> _loadHostelInfo() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('No hostel ID available');
        return;
      }

      final hostelDoc = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .get();

      if (hostelDoc.exists) {
        hostelName.value = hostelDoc.data()?['name'] ?? 'Unknown Hostel';
      }
    } catch (e) {
      _logger.e('Failed to load hostel info', error: e);
      hostelName.value = 'Hostel ${hostelId.value}';
    }
  }

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    isLoading.value = true;

    try {
      if (hostelId.isEmpty) {
        // Try to get hostel ID if it wasn't set initially
        await _initializeUser();

        if (hostelId.isEmpty) {
          throw Exception('Hostel ID not found. Please log in again.');
        }
      }

      // Load data in parallel for efficiency
      await Future.wait([
        _loadGrievancesCount(),
        _loadVouchersCount(),
        _loadStockInfo(),
        _loadFinancialData(),
        _loadRecentTransactions(),
        _loadInventoryCategories()
      ]);
    } catch (e) {
      _logger.e('Failed to load dashboard data', error: e);
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load grievances assigned to manager
  Future<void> _loadGrievancesCount() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.grievances)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('assignedTo', isEqualTo: 'manager')
          .get();

      totalGrievances.value = snapshot.docs.length;
    } catch (e) {
      _logger.e('Error loading grievances count', error: e);
    }
  }

  // Load pending vouchers
  Future<void> _loadVouchersCount() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.vouchers)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('status', isEqualTo: 'pending')
          .get();

      pendingVouchers.value = snapshot.docs.length;
    } catch (e) {
      _logger.e('Error loading vouchers count', error: e);
    }
  }

  // Load stock information
  Future<void> _loadStockInfo() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.stock)
          .where('hostelId', isEqualTo: hostelId.value)
          .get();

      stockItems.value = snapshot.docs.length;

      double total = 0;
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('balance') && doc['balance'] != null) {
          total += double.parse(doc['balance'].toString());
        }
      }
      stockValue.value = total;
    } catch (e) {
      _logger.e('Error loading stock info', error: e);
    }
  }

  // Load financial data
  Future<void> _loadFinancialData() async {
    try {
      // Get budget info
      final budgetDoc = await _firestore
          .collection(FirestoreConstants.budgets)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('month', isEqualTo: DateTime.now().month)
          .where('year', isEqualTo: DateTime.now().year)
          .limit(1)
          .get();

      if (budgetDoc.docs.isNotEmpty) {
        totalBudget.value = budgetDoc.docs.first['amount'] ?? 0.0;
      } else {
        // Sample budget if none exists
        totalBudget.value = 400000.0;
      }

      // Get expenses
      final expensesSnapshot = await _firestore
          .collection(FirestoreConstants.transactions)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('type', isEqualTo: 'expense')
          .where('date',
              isGreaterThanOrEqualTo:
                  DateTime(DateTime.now().year, DateTime.now().month, 1))
          .get();

      double total = 0;
      for (var doc in expensesSnapshot.docs) {
        total += doc['amount'] ?? 0.0;
      }
      totalSpent.value = total;

      // Get bills data
      final billsSnapshot = await _firestore
          .collection(FirestoreConstants.bills)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('month', isEqualTo: DateTime.now().month)
          .where('year', isEqualTo: DateTime.now().year)
          .get();

      double collected = 0.0;
      double pending = 0.0;
      for (var doc in billsSnapshot.docs) {
        if (doc['status'] == 'paid') {
          collected += doc['amount'] ?? 0.0;
        } else {
          pending += doc['amount'] ?? 0.0;
        }
      }

      billsCollected.value = collected;
      billsPending.value = pending;
      savings.value = totalBudget.value > totalSpent.value
          ? (totalBudget.value - totalSpent.value)
          : 0.0;
    } catch (e) {
      _logger.e('Error loading financial data', error: e);
      // Set default values in case of error
      totalBudget.value = 400000.0;
      totalSpent.value = 285000.0;
      billsCollected.value = 145000.0;
      billsPending.value = 38500.0;
      savings.value = 22500.0;
    }
  }

  // Load recent transactions
  Future<void> _loadRecentTransactions() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.transactions)
          .where('hostelId', isEqualTo: hostelId.value)
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      final List<Map<String, dynamic>> transactions = [];

      for (var doc in snapshot.docs) {
        transactions.add({
          'title': doc['title'] ?? 'Transaction',
          'date': (doc['date'] as Timestamp).toDate(),
          'amount': doc['amount'] ?? 0.0,
          'type': doc['type'] ?? 'expense',
        });
      }

      if (transactions.isEmpty) {
        // Sample data if no transactions exist
        recentTransactions.value = [
          {
            'title': 'Rice purchase',
            'date': DateTime.now().subtract(Duration(days: 1)),
            'amount': 12500.0,
            'type': 'expense'
          },
          {
            'title': 'Vegetables delivery',
            'date': DateTime.now().subtract(Duration(days: 2)),
            'amount': 3800.0,
            'type': 'expense'
          },
          {
            'title': 'Bill payments received',
            'date': DateTime.now().subtract(Duration(days: 3)),
            'amount': 25000.0,
            'type': 'income'
          },
        ];
      } else {
        recentTransactions.value = transactions;
      }
    } catch (e) {
      _logger.e('Error loading recent transactions', error: e);
      // Set sample data in case of error
      recentTransactions.value = [
        {
          'title': 'Rice purchase',
          'date': DateTime.now().subtract(Duration(days: 1)),
          'amount': 12500.0,
          'type': 'expense'
        },
        {
          'title': 'Vegetables delivery',
          'date': DateTime.now().subtract(Duration(days: 2)),
          'amount': 3800.0,
          'type': 'expense'
        },
        {
          'title': 'Bill payments received',
          'date': DateTime.now().subtract(Duration(days: 3)),
          'amount': 25000.0,
          'type': 'income'
        },
      ];
    }
  }

  // Load inventory categories
  Future<void> _loadInventoryCategories() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.stockCategories)
          .where('hostelId', isEqualTo: hostelId.value)
          .get();

      final List<Map<String, dynamic>> categories = [];

      for (var doc in snapshot.docs) {
        // Count items in this category
        final itemsSnapshot = await _firestore
            .collection(FirestoreConstants.stock)
            .where('hostelId', isEqualTo: hostelId.value)
            .where('categoryId', isEqualTo: doc.id)
            .get();

        categories.add({
          'name': doc['name'] ?? 'Unknown',
          'count': itemsSnapshot.docs.length,
          'icon': _getCategoryIcon(doc['name'] ?? ''),
          'color': _getCategoryColor(doc['name'] ?? ''),
        });
      }

      if (categories.isEmpty) {
        // Sample data if no categories exist
        inventoryCategories.value = [
          {
            'name': 'Grains & Rice',
            'count': 12,
            'icon': 'grain',
            'color': 'amber'
          },
          {'name': 'Vegetables', 'count': 18, 'icon': 'eco', 'color': 'green'},
          {
            'name': 'Dairy Products',
            'count': 7,
            'icon': 'egg_alt',
            'color': 'blue'
          },
          {'name': 'Spices', 'count': 15, 'icon': 'spa', 'color': 'deepOrange'},
        ];
      } else {
        inventoryCategories.value = categories;
      }
    } catch (e) {
      _logger.e('Error loading inventory categories', error: e);
      // Set sample data in case of error
      inventoryCategories.value = [
        {
          'name': 'Grains & Rice',
          'count': 12,
          'icon': 'grain',
          'color': 'amber'
        },
        {'name': 'Vegetables', 'count': 18, 'icon': 'eco', 'color': 'green'},
        {
          'name': 'Dairy Products',
          'count': 7,
          'icon': 'egg_alt',
          'color': 'blue'
        },
        {'name': 'Spices', 'count': 15, 'icon': 'spa', 'color': 'deepOrange'},
      ];
    }
  }

  // Get icon for category
  String _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('grain') || categoryLower.contains('rice')) {
      return 'grain';
    } else if (categoryLower.contains('vegetable')) {
      return 'eco';
    } else if (categoryLower.contains('dairy')) {
      return 'egg_alt';
    } else if (categoryLower.contains('spice')) {
      return 'spa';
    }
    return 'inventory_2_outlined';
  }

  // Get color for category
  String _getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('grain') || categoryLower.contains('rice')) {
      return 'amber';
    } else if (categoryLower.contains('vegetable')) {
      return 'green';
    } else if (categoryLower.contains('dairy')) {
      return 'blue';
    } else if (categoryLower.contains('spice')) {
      return 'deepOrange';
    }
    return 'primary';
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      if (currentUser.value == null) {
        throw Exception('User not authenticated');
      }

      String hashedPassword = HashHelper.encode(newPassword);

      // First check if this manager exists
      final managersRef = _firestore
          .collection(FirestoreConstants.users)
          .where('role', isEqualTo: 'manager')
          .where('hostelId', isEqualTo: hostelId.value)
          .where('email', isEqualTo: currentUser.value!.email)
          .limit(1);

      final snapshot = await managersRef.get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Manager account not found');
      }

      // Update the password in the users collection
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(snapshot.docs.first.id)
          .update({
        'password': hashedPassword,
      });

      // Also update in loginCredentials for backward compatibility
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc('roles')
          .collection('manager')
          .doc(currentUser.value!.email)
          .update({
        'password': hashedPassword,
      });

      _logger.i(
          'Password changed successfully for manager: ${currentUser.value!.email}');

      Get.snackbar(
        'Success',
        'Password changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _logger.e('Error changing password', error: e);
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Helper to capitalize strings
  String capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
}
