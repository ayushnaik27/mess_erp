import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/mess_bill_screen.dart';
import 'package:mess_erp/student/qr_scanner_screen.dart';
import 'package:mess_erp/student/request_extra_items_screen.dart';
import 'package:mess_erp/student/track_leaves_screen.dart';

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
    // Other refresh operations as needed
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
        'Info',
        'No active meal available for scanning',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(() => QRScannerScreen(rollNumber: rollNumber));
  }

  void navigateToMessBill(String studentId) {
    Get.to(() => MessBillScreen(studentId: studentId));
  }

  void navigateToRequestExtraItems(String rollNumber) {
    Get.toNamed(RequestExtraItemsScreen.routeName, arguments: rollNumber);
  }

  void navigateToApplyLeave(String rollNumber) {
    Get.toNamed(ApplyLeaveScreen.routeName, arguments: rollNumber);
  }

  void navigateToTrackLeaves(String rollNumber) {
    Get.to(() => TrackLeavesScreen(studentRollNumber: rollNumber));
  }

  void navigateToFileGrievance() {
    Get.toNamed('/file-grievance');
  }

  void navigateToTrackComplaints() {
    Get.toNamed('/track-complaints');
  }

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
