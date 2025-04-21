import 'package:get/get.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/clerk/services/clerk_service.dart';

class ClerkDashboardController extends GetxController {
  final ClerkService _clerkService = Get.find<ClerkService>();
  final AppLogger _logger = AppLogger();

  final RxBool isLoading = false.obs;
  final Rx<User> currentUser = Rx<User>(User(
    id: '',
    name: '',
    role: '',
    email: '',
    hostel: '',
    rollNumber: '',
  ));
  final RxString username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _clerkService.getCurrentUser();
      if (userData != null) {
        currentUser.value = userData;
        username.value = userData.name;
      }
    } catch (e) {
      _logger.e('Error loading user data', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.changePassword(newPassword);
      return success;
    } catch (e) {
      _logger.e('Error changing password', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMonthlyReports() {
    Get.toNamed(AppRoutes.monthlyReportScreen);
  }

  void navigateToOpenTender() {
    Get.toNamed(AppRoutes.openTender);
  }

  void navigateToAllTenders() {
    Get.toNamed(AppRoutes.allTenders);
  }

  void navigateToEnrollmentRequests() {
    Get.toNamed(AppRoutes.enrollmentRequests);
  }

  void navigateToAssignedGrievances() {
    Get.toNamed(AppRoutes.assignedGrievances, arguments: {'userType': 'clerk'});
  }

  void logout() {
    _clerkService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
