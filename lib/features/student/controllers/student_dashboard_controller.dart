import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';

class StudentDashboardController extends GetxController {
  final RxBool isMealLive = false.obs;
  final AppLogger _logger = AppLogger();

  // User data
  String? userRollNumber;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userRole = ''.obs;

  void initializeUser(String? rollNumber) {
    userRollNumber = rollNumber;
    if (rollNumber != null && rollNumber.isNotEmpty) {
      _fetchUserDetails(rollNumber);
    }
  }

  Future<void> _fetchUserDetails(String rollNumber) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDetails =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(rollNumber)
              .get();

      userName.value = userDetails['name'] ?? '';
      userRole.value = userDetails['role'] ?? '';
      // Email field might be missing for some users
      userEmail.value = userDetails['email'] ?? '';

      _logger.i('User details fetched: ${userName.value}');
    } catch (e) {
      _logger.e('Error fetching user details', error: e);
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkMealStatus();
  }

  Future<void> refreshData() async {
    await checkMealStatus();
    if (userRollNumber != null && userRollNumber!.isNotEmpty) {
      await _fetchUserDetails(userRollNumber!);
    }
    _logger.i('Dashboard data refreshed');
  }

  Future<void> checkMealStatus() async {
    try {
      FirebaseFirestore.instance
          .collection(FirestoreConstants.meal)
          .doc('meal')
          .snapshots()
          .listen((event) {
        isMealLive.value = event.data()?['status'] == 'started';
      });
    } catch (e) {
      _logger.e('Error checking meal status', error: e);
    }
  }

  Future<bool> submitLeaveRequest({
    required String rollNumber,
    required DateTime fromDate,
    required DateTime toDate,
    required String fromMeal,
    required String toMeal,
    required List<String> mealOptions,
  }) async {
    try {
      _logger.i('Submitting leave request for $rollNumber');

      return true;
    } catch (e) {
      _logger.e('Error submitting leave request', error: e);
      return false;
    }
  }

  void navigateToQrScanner(String rollNumber) {
    if (!isMealLive.value) {
      Get.snackbar(
        AppStrings.info,
        AppStrings.noActiveMeal,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(AppRoutes.qrScanner, arguments: {'rollNumber': rollNumber});
  }

  void navigateToMessBill(String studentId) {
    Get.toNamed(AppRoutes.messBill, arguments: {'studentId': studentId});
  }

  void navigateToRequestExtraItems(String rollNumber) {
    Get.toNamed(AppRoutes.requestExtraItems,
        arguments: {'rollNumber': rollNumber});
  }

  void navigateToApplyLeave(String rollNumber) {
    Get.toNamed(AppRoutes.applyLeave, arguments: {'rollNumber': rollNumber});
  }

  void navigateToTrackLeaves(String rollNumber) {
    Get.toNamed(AppRoutes.trackLeaves, arguments: {'rollNumber': rollNumber});
  }

  void navigateToFileGrievance() {
    Get.toNamed(AppRoutes.fileGrievance,
        arguments:
            userRollNumber != null ? {'rollNumber': userRollNumber} : null);
  }

  void navigateToTrackComplaints() {
    Get.toNamed(AppRoutes.trackComplaints,
        arguments:
            userRollNumber != null ? {'rollNumber': userRollNumber} : null);
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
