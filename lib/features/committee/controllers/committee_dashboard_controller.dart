import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/enums/user_role.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/features/committee/models/committee_user.dart';
import 'package:mess_erp/features/committee/repositories/committee_repository.dart';
import 'package:mess_erp/features/student/models/announcement_model.dart';
import 'package:mess_erp/features/student/services/announcement_service.dart';
import 'package:mess_erp/helpers/mess_menu_helper.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class CommitteeDashboardController extends GetxController {
  final CommitteeRepository _repository = CommitteeRepository();
  final AnnouncementService _announcementService = AnnouncementService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<CommitteeUser> user = CommitteeUser(
    name: '',
    username: '',
    password: '',
    role: UserRole.committee.value,
    email: '',
    hostelId: '',
  ).obs;

  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAnnouncementsLoading = false.obs;
  final RxInt pendingGrievancesCount = 0.obs;

  // Statistics for dashboard
  final RxInt totalStudentsCount = 0.obs;
  final RxInt totalAnnouncementsCount = 0.obs;
  final RxDouble totalBillAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // Get user data from current provider (will be replaced with direct fetch)
      await _fetchUserData();

      // Fetch dashboard stats in parallel
      await Future.wait([
        _fetchAnnouncements(),
        _fetchDashboardStats(),
        _fetchPendingGrievancesCount(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load dashboard data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      // First check if we have user data passed from previous screen
      final userData = Get.arguments as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('user')) {
        user.value = CommitteeUser.fromJson(userData['user']);
      } else {
        // Try to get hostelId from storage or from args
        String? hostelId;
        if (userData != null && userData.containsKey('hostelId')) {
          hostelId = userData['hostelId'];
        }

        // Fetch committee user by hostel ID
        final committeeUser =
            await _repository.getCommitteeUser(hostelId: hostelId);

        if (committeeUser != null) {
          user.value = committeeUser;
        } else {
          // If no user found, try to get any committee user
          final anyCommitteeUser = await _repository.getCommitteeUser();
          if (anyCommitteeUser != null) {
            user.value = anyCommitteeUser;
          } else {
            throw Exception('No committee user found');
          }
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load user data: ${e.toString()}';
    }
  }

  Future<void> _fetchAnnouncements() async {
    try {
      isAnnouncementsLoading.value = true;
      // Delete old announcements first
      await _announcementService.deleteOldAnnouncements();

      // Then get current announcements
      // final announcements = await _announcementService.getAnnouncementsAsList();
      // this.announcements.value = announcements;
      // totalAnnouncementsCount.value = announcements.length;
    } catch (e) {
      print('Error fetching announcements: $e');
    } finally {
      isAnnouncementsLoading.value = false;
    }
  }

  Future<void> _fetchDashboardStats() async {
    try {
      // Get student count
      final studentsQuery = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .count()
          .get();

      totalStudentsCount.value = studentsQuery.count ?? 0;

      // Calculate total bills amount for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final billsQuery = await FirebaseFirestore.instance
          .collection('bills')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      double total = 0;
      for (var doc in billsQuery.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      totalBillAmount.value = total;
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  Future<void> _fetchPendingGrievancesCount() async {
    try {
      final grievancesQuery = await FirebaseFirestore.instance
          .collection('grievances')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      pendingGrievancesCount.value = grievancesQuery.count ?? 0;
    } catch (e) {
      print('Error fetching pending grievances count: $e');
    }
  }

  Future<void> refreshDashboard() async {
    await _initializeData();
  }

  Future<void> changePassword(String newPassword) async {
    try {
      isLoading.value = true;
      String hashedPassword = HashHelper.encode(newPassword);
      final String userId = user.value.id;

      if (userId.isNotEmpty) {
        // Direct document reference if we have the user ID
        await _firestore.collection('users').doc(userId).update({
          'password': hashedPassword,
        });
      } else {
        // Fallback to query by email and role
        final hostelId = user.value.hostelId;
        final docId = 'committee_$hostelId';

        await _firestore.collection('users').doc(docId).update({
          'password': hashedPassword,
        });
      }

      user.value = user.value.copyWith(password: hashedPassword);

      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewMessMenu() async {
    try {
      isLoading.value = true;

      // Check if user has a hostel ID
      final hostelId = user.value.hostelId.isNotEmpty
          ? user.value.hostelId
          : 'default_hostel';

      Get.toNamed(AppRoutes.messMenuOperations, arguments: {
        'hostelId': hostelId,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open mess menu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadMessMenu() async {
    try {
      isLoading.value = true;
      final result = await MessMenuHelper.pickDocsFile();
      return result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload mess menu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
