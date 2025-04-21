import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';

class StudentDashboardController extends GetxController {
  final RxBool isMealLive = false.obs;
  final AppLogger _logger = AppLogger();

  String? userRollNumber;

  void initializeUser(String? rollNumber) {
    userRollNumber = rollNumber;
  }

  @override
  void onInit() {
    super.onInit();
    checkMealStatus();
  }

  Future<void> refreshData() async {
    await checkMealStatus();
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
    // Pass the current user's roll number if needed
    Get.toNamed(AppRoutes.fileGrievance,
        arguments:
            userRollNumber != null ? {'rollNumber': userRollNumber} : null);
  }

  void navigateToTrackComplaints() {
    // Pass the current user's roll number if needed
    Get.toNamed(AppRoutes.trackComplaints,
        arguments:
            userRollNumber != null ? {'rollNumber': userRollNumber} : null);
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
