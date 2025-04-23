import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/clerk/bindings/enrollment_request_bindings.dart';
import 'package:mess_erp/features/clerk/controllers/enrollment_request_controller.dart';

class EnrollmentRequestScreen extends StatelessWidget {
  const EnrollmentRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    EnrollmentRequestBinding().dependencies();
    final controller = Get.find<EnrollmentRequestController>();
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Enrollment Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.sortBy.value == 'timestamp'
                      ? Icons.sort
                      : Icons.sort_by_alpha,
                  color: AppColors.primary,
                ),
                onPressed: () => _showSortOptions(context, controller),
                tooltip: 'Sort requests',
              )),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.fetchEnrollmentRequests,
              color: AppColors.primary,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (controller.enrollmentRequests.isEmpty) {
                  return _buildEmptyState(controller);
                }

                if (controller.filteredRequests.isEmpty) {
                  return _buildNoResultsState(
                      controller.searchQuery.value, controller);
                }

                return ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: controller.filteredRequests.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> request =
                        controller.filteredRequests[index];
                    return _buildRequestCard(request, controller, index);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(EnrollmentRequestController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          onChanged: (value) => controller.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Search by name or roll number...',
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
    EnrollmentRequestController controller,
    int index,
  ) {
    String id = request['id'];
    String name = request['name'];
    String rollNumber = request['rollNumber'];
    String email = request['email'] ?? '';
    String hostel = request['hostel'] ?? 'Not specified';
    Timestamp timestamp = request['timestamp'] ?? Timestamp.now();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      radius: 24.r,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                rollNumber,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatTimeAgo(timestamp.toDate()),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (email.isNotEmpty) ...[
                            _buildInfoRow(Icons.email_outlined, email),
                            SizedBox(height: 8.h),
                          ],
                          _buildInfoRow(Icons.home_outlined, hostel),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => TextButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () => _showRejectConfirmation(controller, id, name),
                      icon: Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 20.sp,
                      ),
                      label: Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    )),
                SizedBox(width: 12.w),
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () => _showApproveConfirmation(controller, request),
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      label: Text(
                        'Approve',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(
          duration: 400.ms,
          delay: Duration(milliseconds: 50 * index),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
          delay: Duration(milliseconds: 50 * index),
        );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(EnrollmentRequestController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No enrollment requests',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no pending enrollment requests at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.fetchEnrollmentRequests(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(
      String query, EnrollmentRequestController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 70.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'No matches found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No results matching "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          TextButton.icon(
            onPressed: () => controller.searchQuery.value = '',
            icon: Icon(Icons.clear),
            label: Text('Clear Search'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(
      BuildContext context, EnrollmentRequestController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() => _buildSortOption(
                    title: 'Date (Newest first)',
                    isSelected: controller.sortBy.value == 'timestamp' &&
                        !controller.sortAscending.value,
                    onTap: () {
                      controller.sortBy.value = 'timestamp';
                      controller.sortAscending.value = false;
                      controller.sortRequests('timestamp');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _buildSortOption(
                    title: 'Date (Oldest first)',
                    isSelected: controller.sortBy.value == 'timestamp' &&
                        controller.sortAscending.value,
                    onTap: () {
                      controller.sortBy.value = 'timestamp';
                      controller.sortAscending.value = true;
                      controller.sortRequests('timestamp');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _buildSortOption(
                    title: 'Name (A-Z)',
                    isSelected: controller.sortBy.value == 'name' &&
                        controller.sortAscending.value,
                    onTap: () {
                      controller.sortBy.value = 'name';
                      controller.sortAscending.value = true;
                      controller.sortRequests('name');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _buildSortOption(
                    title: 'Name (Z-A)',
                    isSelected: controller.sortBy.value == 'name' &&
                        !controller.sortAscending.value,
                    onTap: () {
                      controller.sortBy.value = 'name';
                      controller.sortAscending.value = false;
                      controller.sortRequests('name');
                      Navigator.pop(context);
                    },
                  )),
              Obx(() => _buildSortOption(
                    title: 'Roll Number',
                    isSelected: controller.sortBy.value == 'rollNumber',
                    onTap: () {
                      controller.sortBy.value = 'rollNumber';
                      controller.sortAscending.value = true;
                      controller.sortRequests('rollNumber');
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showRejectConfirmation(
    EnrollmentRequestController controller,
    String id,
    String name,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Reject Request'),
        content: Text(
            'Are you sure you want to reject the enrollment request from $name?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.rejectRequest(id, name);
            },
            child: Text(
              'Reject',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveConfirmation(
    EnrollmentRequestController controller,
    Map<String, dynamic> request,
  ) {
    String name = request['name'];

    Get.dialog(
      AlertDialog(
        title: Text('Approve Request'),
        content: Text(
            'Are you sure you want to approve the enrollment request from $name?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.approveRequest(request);
            },
            child: Text(
              'Approve',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
