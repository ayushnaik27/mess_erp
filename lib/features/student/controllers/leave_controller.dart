import 'package:get/get.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/student/models/leave_application_model.dart';
import 'package:mess_erp/features/student/models/meal_opt_out_model.dart';
import 'package:mess_erp/features/student/services/leave_service.dart';
import 'package:flutter/material.dart';

class LeaveController extends GetxController {
  final LeaveService _leaveService = Get.put(LeaveService());
  final AppLogger _logger = AppLogger();

  final RxBool isLoading = false.obs;
  final RxList<LeaveApplication> activeLeaves = <LeaveApplication>[].obs;
  final RxList<LeaveApplication> pastLeaves = <LeaveApplication>[].obs;

  Future<void> applyLeave({
    required String studentId,
    required String name,
    required String hostelId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required List<MealOptOut> mealsOptedOut,
  }) async {
    try {
      isLoading.value = true;

      final success = await _leaveService.applyLeave(
        hostelId: hostelId,
        studentId: studentId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        mealsOptedOut: mealsOptedOut,
      );

      if (success) {
        Get.back(); // Go back to previous screen

        Get.snackbar(
          'Success',
          'Leave application submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit leave application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error applying for leave', error: e);

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load leaves for tracking screen
  void loadLeaves(String hostelId, String studentId) {
    _leaveService.getStudentLeaves(hostelId, studentId).listen(
      (leaves) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Split into active and past leaves
        activeLeaves.value = leaves
            .where((leave) =>
                leave.endDate.isAfter(today) || isSameDay(leave.endDate, today))
            .toList();

        pastLeaves.value = leaves
            .where((leave) =>
                leave.endDate.isBefore(today) &&
                !isSameDay(leave.endDate, today))
            .toList();
      },
      onError: (error) {
        _logger.e('Error loading leaves', error: error);
      },
    );
  }

  /// Cancel a leave application
  Future<void> cancelLeave(String hostelId, LeaveApplication leave) async {
    try {
      isLoading.value = true;

      if (leave.id == null) {
        throw Exception('Leave ID is null');
      }

      final success = await _leaveService.cancelLeave(hostelId, leave.id!);

      if (success) {
        Get.snackbar(
          'Success',
          'Leave cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel leave',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error cancelling leave', error: e);

      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void navigateToApplyLeave(String studentId) {
    Get.toNamed(AppRoutes.applyLeave);
  }
}
