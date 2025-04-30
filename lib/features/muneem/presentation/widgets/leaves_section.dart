import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';

class LeavesSection extends StatelessWidget {
  final MuneemDashboardController controller;

  const LeavesSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.beach_access,
                      color: Colors.orange,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Obx(() => Text(
                          '${controller.leaveStudentCount.value} ${AppStrings.studentsOnLeave}',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ],
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed('/studentsOnLeave'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    AppStrings.viewAll,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.studentsOnLeave.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Text(
                    AppStrings.noStudentsOnLeave,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.studentsOnLeave.length > 3
                  ? 3
                  : controller.studentsOnLeave.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final leave = controller.studentsOnLeave[index];
                return _buildStudentOnLeaveItem(
                  leave.studentName,
                  leave.rollNumber,
                  leave.reason,
                  leave.startDate,
                  leave.endDate,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentOnLeaveItem(
    String name,
    String rollNumber,
    String reason,
    DateTime startDate,
    DateTime endDate,
  ) {
    final DateFormat dateFormat = DateFormat('dd MMM');

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
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
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      rollNumber,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      width: 4.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      reason,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
