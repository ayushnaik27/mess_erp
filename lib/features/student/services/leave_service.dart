import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/enums/leave_status.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/student/models/leave_application_model.dart';
import 'package:mess_erp/features/student/models/meal_opt_out_model.dart';

class LeaveService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  static LeaveService get to => Get.find<LeaveService>();

  /// Apply for a new leave
  Future<bool> applyLeave({
    required String hostelId,
    required String studentId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required List<MealOptOut> mealsOptedOut,
  }) async {
    try {
      // Create the leave application
      final leaveApplication = LeaveApplication(
        studentId: studentId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: LeaveStatus.approved, // Auto-approved as per requirement
        appliedAt: DateTime.now(),
        reviewedAt: DateTime.now(), // Auto-approved, so reviewedAt is now
        reviewedBy: 'system',
        mealsOptedOut: mealsOptedOut,
      );

      // Add to Firestore under hostel/leaves collection
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('leaves')
          .add(leaveApplication.toJson());

      // Update the statistics (optional, but good for dashboard metrics)
      _updateLeaveStatistics(hostelId, mealsOptedOut.length);

      return true;
    } catch (e) {
      _logger.e('Error applying for leave', error: e);
      return false;
    }
  }

  /// Get all leave applications for a student
  Stream<List<LeaveApplication>> getStudentLeaves(
      String hostelId, String studentId) {
    return _firestore
        .collection(FirestoreConstants.hostels)
        .doc(hostelId)
        .collection('leaves')
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaveApplication.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get active leaves for a student (for today or future dates)
  Stream<List<LeaveApplication>> getActiveLeaves(
      String hostelId, String studentId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection(FirestoreConstants.hostels)
        .doc(hostelId)
        .collection('leaves')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: LeaveStatus.approved.name)
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaveApplication.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Cancel a leave application
  Future<bool> cancelLeave(String hostelId, String leaveId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('leaves')
          .doc(leaveId)
          .update({
        'status': LeaveStatus.rejected.name,
        'reviewedAt': Timestamp.now(),
        'comments': 'Cancelled by student'
      });
      return true;
    } catch (e) {
      _logger.e('Error cancelling leave', error: e);
      return false;
    }
  }

  /// Update leave statistics
  Future<void> _updateLeaveStatistics(String hostelId, int mealCount) async {
    try {
      final statsRef = _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('statistics')
          .doc('leaveStats');

      // Use transaction to safely update counters
      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(statsRef);
        if (statsDoc.exists) {
          final currentTotal = statsDoc.data()?['totalApprovedLeaves'] ?? 0;
          final currentActive = statsDoc.data()?['currentLeaves'] ?? 0;

          transaction.update(statsRef, {
            'totalApprovedLeaves': currentTotal + 1,
            'currentLeaves': currentActive + 1,
          });
        } else {
          transaction.set(statsRef, {
            'totalApprovedLeaves': 1,
            'currentLeaves': 1,
            'totalRejectedLeaves': 0,
          });
        }
      });
    } catch (e) {
      _logger.e('Error updating leave statistics', error: e);
    }
  }
}
