import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/enums/leave_status.dart';
import 'package:mess_erp/core/extensions/leave_status_extension.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/services/user_service.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/student/controllers/leave_controller.dart';
import 'package:mess_erp/features/student/models/leave_application_model.dart';

class TrackLeavesScreen extends StatefulWidget {
  final String studentRollNumber;

  const TrackLeavesScreen({super.key, required this.studentRollNumber});

  @override
  State<TrackLeavesScreen> createState() => _TrackLeavesScreenState();
}

class _TrackLeavesScreenState extends State<TrackLeavesScreen>
    with SingleTickerProviderStateMixin {
  final LeaveController _controller = Get.put(LeaveController());
  late TabController _tabController;
  final dateFormat = DateFormat('dd MMM, yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = UserService.to.currentUser.value;
    if (user != null) {
      _controller.loadLeaves(user.hostelId, user.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Leaves',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeavesList(true),
          _buildLeavesList(false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.back();
          final user = UserService.to.currentUser.value;
          if (user != null) {
            _controller.navigateToApplyLeave(user.id);
          }
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, size: 20.sp),
        label: Text(
          'New Leave',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildLeavesList(bool isActive) {
    return Obx(() {
      final leaves =
          isActive ? _controller.activeLeaves : _controller.pastLeaves;

      if (_controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                'Loading your leaves...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      if (leaves.isEmpty) {
        return _buildEmptyState(isActive);
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        itemCount: leaves.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final leave = leaves[index];
          return _buildLeaveCard(leave, isActive);
        },
      );
    });
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.event_available : Icons.history,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            isActive ? 'No active leaves' : 'No leave history',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              isActive
                  ? 'You don\'t have any active leaves. Create a new leave application by tapping the button below.'
                  : 'Your past leaves will appear here once you have taken leaves.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          if (isActive)
            ElevatedButton.icon(
              onPressed: () {
                final user = UserService.to.currentUser.value;
                if (user != null) {
                  _controller.navigateToApplyLeave(user.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.add, size: 18.sp),
              label: Text(
                'Apply for Leave',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveApplication leave, bool isActive) {
    final user = UserService.to.currentUser.value;
    final duration = leave.endDate.difference(leave.startDate).inDays + 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator bar
          Container(
            height: 6.h,
            color: leave.status.color,
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and date
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: leave.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            leave.status == LeaveStatus.approved
                                ? Icons.check_circle
                                : leave.status == LeaveStatus.rejected
                                    ? Icons.cancel
                                    : Icons.pending,
                            size: 14.sp,
                            color: leave.status.color,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            leave.status.displayText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: leave.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Applied on ${_getRelativeTimeText(leave.appliedAt)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Date range with calendar icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.date_range,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$duration ${duration == 1 ? 'day' : 'days'} leave',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Reason
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.description,
                        color: Colors.amber.shade800,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            leave.reason,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action buttons if active
                if (isActive && leave.status == LeaveStatus.approved) ...[
                  SizedBox(height: 16.h),
                  Divider(
                    color: Colors.grey.shade200,
                    thickness: 1,
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCancelConfirmation(leave, user!.hostelId);
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: 18.sp,
                        color: Colors.red,
                      ),
                      label: Text(
                        'Cancel Leave',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return dateFormat.format(dateTime);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showCancelConfirmation(LeaveApplication leave, String hostelId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Cancel Leave',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to cancel this leave? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'No, Keep It',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _controller.cancelLeave(hostelId, leave);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
