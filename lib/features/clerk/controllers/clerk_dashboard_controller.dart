import 'package:get/get.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/controllers/auth_controller.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/clerk/services/clerk_service.dart';

class ClerkDashboardController extends GetxController {
  late final ClerkService _clerkService;
  final AuthController _authController = Get.find<AuthController>();
  final AppLogger _logger = AppLogger();

  final RxBool isLoading = false.obs;
  final Rx<User> currentUser = Rx<User>(User(
    id: '',
    name: '',
    role: '',
    email: '',
    hostelId: '',
    rollNumber: '',
  ));
  final RxString username = ''.obs;
  final RxString hostelId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final Map<String, dynamic>? args = Get.arguments;
    hostelId.value = args?['hostelId'] ?? '';
    username.value = args?['username'] ?? '';

    final persistenceService = await AuthPersistenceService.getInstance();

    _clerkService = ClerkService(hostelId.value, persistenceService);

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final userData = await _clerkService.getCurrentUser();
      if (userData != null) {
        currentUser.value = userData;
        username.value = userData.name;
        hostelId.value = userData.hostelId;
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

  Future<bool> addStudent(
      String name, String rollNumber, String email, String phoneNumber) async {
    try {
      isLoading.value = true;
      final success =
          await _clerkService.addStudent(name, rollNumber, email, phoneNumber);
      return success;
    } catch (e) {
      _logger.e('Error adding student', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addManager(String name, String email, String phoneNumber) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addManager(name, email, phoneNumber);
      return success;
    } catch (e) {
      _logger.e('Error adding manager', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMuneem(String name, String email, String phoneNumber) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addMuneem(name, email, phoneNumber);
      return success;
    } catch (e) {
      _logger.e('Error adding muneem', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCommitteeMember(
      String name, String email, String phoneNumber) async {
    try {
      isLoading.value = true;
      final success =
          await _clerkService.addCommitteeMember(name, email, phoneNumber);
      return success;
    } catch (e) {
      _logger.e('Error adding committee member', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addVendor(
      String name, String contactNumber, String email) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addVendor(name, contactNumber, email);
      return success;
    } catch (e) {
      _logger.e('Error adding vendor', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> imposeFine(
      String rollNumber, double amount, String reason) async {
    try {
      isLoading.value = true;
      final success =
          await _clerkService.imposeStudentFine(rollNumber, amount, reason);
      return success;
    } catch (e) {
      _logger.e('Error imposing fine', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMonthlyReports() {
    Get.toNamed(AppRoutes.monthlyReportScreen,
        arguments: {'hostelId': hostelId.value});
  }

  void navigateToOpenTender() {
    Get.toNamed(AppRoutes.openTender, arguments: {'hostelId': hostelId.value});
  }

  void navigateToAllTenders() {
    Get.toNamed(AppRoutes.allTenders, arguments: {'hostelId': hostelId.value});
  }

  void navigateToEnrollmentRequests() {
    Get.toNamed(AppRoutes.enrollmentRequests,
        arguments: {'hostelId': hostelId.value});
  }

  void navigateToAssignedGrievances() {
    Get.toNamed(AppRoutes.assignedGrievances,
        arguments: {'userType': 'clerk', 'hostelId': hostelId.value});
  }

  void logout() {
    _authController.logout();
  }
}
