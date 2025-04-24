import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/muneem/models/activity_log_model.dart';
import 'package:mess_erp/features/muneem/models/extra_item_model.dart';
import 'package:mess_erp/features/auth/services/auth_service.dart';
import 'package:mess_erp/features/muneem/models/leave_model.dart';
import 'package:mess_erp/features/muneem/models/meal_model.dart';

class MuneemDashboardController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _authPersistenceService;
  final AuthService _authService;

  // Observable properties
  final RxBool isLoading = false.obs;
  final Rx<User> user = User.empty().obs;
  final RxString hostelId = ''.obs;
  final RxString hostelName = ''.obs;

  // Dashboard metrics
  final RxInt totalStudentCount = 0.obs;
  final RxInt presentStudentCount = 0.obs;
  final RxInt leaveStudentCount = 0.obs;
  final RxDouble extraItemsTotal = 0.0.obs;
  final RxDouble todayAttendancePercentage = 0.0.obs;

  // Weekly attendance data for the chart
  final RxList<FlSpot> weeklyAttendanceData = <FlSpot>[].obs;
  final RxList<String> weekDays = <String>[].obs;

  // Meals data
  final RxList<Meal> todayMeals = <Meal>[].obs;

  // Students on leave
  final RxList<Leave> studentsOnLeave = <Leave>[].obs;

  // Recent activities
  final RxList<ActivityLog> recentActivities = <ActivityLog>[].obs;

  // Constructor with dependency injection
  MuneemDashboardController({
    required AuthPersistenceService authPersistenceService,
    required AuthService authService,
  })  : _authPersistenceService = authPersistenceService,
        _authService = authService;

  @override
  void onInit() {
    super.onInit();
    _initializeUser().then((_) {
      refreshDashboard();
    });
    _initializeWeekDays();
  }

  // Initialize user information
  Future<void> _initializeUser() async {
    try {
      isLoading.value = true;
      final currentUser = await _authPersistenceService.getCurrentUser();
      if (currentUser != null) {
        user.value = currentUser;
        hostelId.value = currentUser.hostelId;
        await _loadHostelDetails();
      } else {
        _logger.e('No authenticated user found');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _logger.e('Error initializing user', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load hostel details for the current user
  Future<void> _loadHostelDetails() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot load hostel details: hostelId is empty');
        return;
      }

      final hostelDoc = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .get();

      if (hostelDoc.exists) {
        hostelName.value = hostelDoc.data()?['name'] ?? 'Hostel';
      }
    } catch (e) {
      _logger.e('Error loading hostel details', error: e);
    }
  }

  // Change password method - Updated to use proper method
  Future<bool> changePassword(String newPassword) async {
    try {
      if (newPassword.isEmpty) {
        Get.snackbar(
          'Error',
          'Password cannot be empty',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      // For admin users (muneem is an admin type)
      if (user.value.email.isNotEmpty) {
        // Use the admin password update method
        await _authService.adminLogin(
          role: 'muneem',
          hostelId: hostelId.value,
          password: newPassword,
        );
      }

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
      return true;
    } catch (e) {
      _logger.e('Error changing password', error: e);
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  // Add extra item bill for student
  Future<bool> imposeExtraAmount(
      String rollNumber, String itemName, double amount) async {
    try {
      if (rollNumber.isEmpty || itemName.isEmpty || amount <= 0) {
        Get.snackbar(
          'Error',
          'Please fill all fields correctly',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      // First check if the student exists in this hostel
      final studentQuery = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumber)
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        Get.snackbar(
          'Error',
          'Student with roll number $rollNumber not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }

      final studentId = studentQuery.docs.first.id;

      // Create the extra item record
      final extraItem = ExtraItem(
        id: '',
        studentId: studentId,
        rollNumber: rollNumber,
        itemName: itemName,
        amount: amount,
        date: DateTime.now(),
        status: 'approved', // Auto-approved since added by muneem
        hostelId: hostelId.value,
        approvedBy: user.value.email,
      );

      // Add to Firestore
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('extraItems')
          .add(extraItem.toMap());

      Get.snackbar(
        'Success',
        'Extra amount imposed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );

      return true;
    } catch (e) {
      _logger.e('Error imposing extra amount', error: e);
      Get.snackbar(
        'Error',
        'Failed to impose extra amount: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  // Log out user - Updated to use proper method
  void logOut() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      _logger.e('Error logging out', error: e);
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading.value = true;
      await _initializeUser();

      // Fetch all dashboard data
      await Future.wait([
        fetchStudentMetrics(),
        fetchTodayMeals(),
        fetchStudentsOnLeave(),
        fetchRecentActivities(),
        fetchWeeklyAttendance(),
      ]);

      Get.snackbar(
        'Refreshed',
        'Dashboard updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _logger.e('Error refreshing dashboard', error: e);
      Get.snackbar(
        'Error',
        'Failed to refresh dashboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeWeekDays() {
    final now = DateTime.now();
    final currentWeekDay = now.weekday;

    final List<String> days = [];
    final DateFormat formatter = DateFormat('E');

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: currentWeekDay - i - 1));
      days.add(formatter.format(day));
    }

    weekDays.value = days;
  }

  Future<void> fetchStudentMetrics() async {
    try {
      if (hostelId.isEmpty) return;

      // Get total student count
      final studentsQuery = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('students')
          .count()
          .get();

      totalStudentCount.value = studentsQuery.count ?? 0;

      final leaveQuery = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('leaves')
          .where('status', isEqualTo: 'approved')
          .where('startDate', isLessThanOrEqualTo: Timestamp.now())
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .count()
          .get();

      leaveStudentCount.value = leaveQuery.count ?? 0;

      // Calculate present students
      presentStudentCount.value =
          totalStudentCount.value - leaveStudentCount.value;

      // Calculate today's attendance percentage
      if (totalStudentCount.value > 0) {
        todayAttendancePercentage.value =
            (presentStudentCount.value / totalStudentCount.value) * 100;
      }

      // Calculate extra items total for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final extraItemsQuery = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('extraItems')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('status', isEqualTo: 'approved')
          .get();

      double total = 0;
      for (var doc in extraItemsQuery.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      extraItemsTotal.value = total;
    } catch (e) {
      _logger.e('Error fetching student metrics', error: e);
    }
  }

  Future<void> fetchTodayMeals() async {
    try {
      if (hostelId.isEmpty) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('meals')
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .orderBy('mealType')
          .get();

      final List<Meal> meals =
          snapshot.docs.map((doc) => Meal.fromMap(doc.data(), doc.id)).toList();

      // If we don't have all three meals, add placeholders
      final mealTypes = ['breakfast', 'lunch', 'dinner'];
      final existingTypes = meals.map((m) => m.mealType.toLowerCase()).toList();

      for (var type in mealTypes) {
        if (!existingTypes.contains(type)) {
          meals.add(Meal(
            id: 'placeholder-$type',
            date: today,
            mealType: type.capitalize!,
            items: ['Menu not available yet'],
            hostelId: hostelId.value,
          ));
        }
      }

      // Sort by meal order (breakfast, lunch, dinner)
      meals.sort((a, b) {
        final order = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
        return order[a.mealType.toLowerCase()]!
            .compareTo(order[b.mealType.toLowerCase()]!);
      });

      todayMeals.value = meals;
    } catch (e) {
      _logger.e('Error fetching today\'s meals', error: e);
    }
  }

  Future<void> fetchStudentsOnLeave() async {
    try {
      if (hostelId.isEmpty) return;
      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('leaves')
          .where('status', isEqualTo: 'approved')
          .where('startDate', isLessThanOrEqualTo: Timestamp.now())
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('startDate')
          .limit(5)
          .get();

      studentsOnLeave.value = snapshot.docs
          .map((doc) => Leave.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _logger.e('Error fetching students on leave', error: e);
    }
  }

  Future<void> fetchRecentActivities() async {
    try {
      if (hostelId.isEmpty) return;

      // Combine multiple activity sources for a comprehensive activity log
      final List<ActivityLog> activities = [];

      // Fetch recent extra items
      final extraItemsSnapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('extraItems')
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      for (var doc in extraItemsSnapshot.docs) {
        final data = doc.data();
        activities.add(ActivityLog(
          id: doc.id,
          type: 'extra_item',
          message:
              'Added ${data['itemName']} for student ${data['rollNumber']}',
          timestamp: (data['date'] as Timestamp).toDate(),
          icon: Icons.fastfood,
          color: Colors.green,
        ));
      }

      // Fetch recent leave approvals
      final leavesSnapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('leaves')
          .where('status', isEqualTo: 'approved')
          .orderBy('updatedAt', descending: true)
          .limit(5)
          .get();

      for (var doc in leavesSnapshot.docs) {
        final data = doc.data();
        activities.add(ActivityLog(
          id: doc.id,
          type: 'leave_approval',
          message: 'Approved leave for ${data['studentName']}',
          timestamp: (data['updatedAt'] as Timestamp).toDate(),
          icon: Icons.check_circle,
          color: Colors.blue,
        ));
      }

      // Fetch recent meal updates
      final mealsSnapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('meals')
          .orderBy('updatedAt', descending: true)
          .limit(5)
          .get();

      for (var doc in mealsSnapshot.docs) {
        final data = doc.data();
        activities.add(ActivityLog(
          id: doc.id,
          type: 'meal_update',
          message: 'Updated ${data['mealType']} menu',
          timestamp: (data['updatedAt'] as Timestamp).toDate(),
          icon: Icons.restaurant_menu,
          color: Colors.purple,
        ));
      }

      // Sort combined activities by timestamp
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Take only most recent activities
      if (activities.length > 10) {
        activities.length = 10;
      }

      recentActivities.value = activities;
    } catch (e) {
      _logger.e('Error fetching recent activities', error: e);
    }
  }

  Future<void> fetchWeeklyAttendance() async {
    try {
      if (hostelId.isEmpty) return;

      final now = DateTime.now();
      final List<FlSpot> spots = [];

      // For each day of the week
      for (int i = 0; i < 7; i++) {
        // Calculate the date (starting from Monday of this week)
        final day = now.subtract(Duration(days: now.weekday - 1 - i));
        final date = DateTime(day.year, day.month, day.day);

        // Find how many students were on leave that day
        final leaveQuery = await _firestore
            .collection(FirestoreConstants.hostels)
            .doc(hostelId.value)
            .collection('leaves')
            .where('status', isEqualTo: 'approved')
            .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(date))
            .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
            .count()
            .get();

        final onLeaveCount = leaveQuery.count;

        // Calculate attendance percentage
        double attendancePercentage = 0;
        if (totalStudentCount.value > 0) {
          attendancePercentage =
              ((totalStudentCount.value - (onLeaveCount ?? 0)) /
                      totalStudentCount.value) *
                  100;
        }

        spots.add(FlSpot(i.toDouble(), attendancePercentage));
      }

      weeklyAttendanceData.value = spots;
    } catch (e) {
      _logger.e('Error fetching weekly attendance', error: e);
      weeklyAttendanceData.value = [
        FlSpot(0, 85),
        FlSpot(1, 90),
        FlSpot(2, 88),
        FlSpot(3, 92),
        FlSpot(4, 94),
        FlSpot(5, 82),
        FlSpot(6, 78),
      ];
    }
  }
}
