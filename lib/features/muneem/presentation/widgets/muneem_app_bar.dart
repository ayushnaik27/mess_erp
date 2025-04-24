import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/dialogs.dart';

class MuneemAppBar extends StatelessWidget {
  final MuneemDashboardController controller;
  final bool innerBoxIsScrolled;

  const MuneemAppBar({
    Key? key,
    required this.controller,
    required this.innerBoxIsScrolled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.primary,
      title: Text(
        AppStrings.muneemDashboard,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: _buildActions(context),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: kToolbarHeight + 20.h,
                bottom: 16.h,
              ),
              child: _buildFlexibleContent(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: controller.refreshDashboard,
        tooltip: AppStrings.refreshData,
      ),
      IconButton(
        icon: const Icon(Icons.qr_code, color: Colors.white),
        onPressed: () => Get.toNamed('/showQR'),
        tooltip: AppStrings.scanQRCode,
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (value) {
          if (value == 'password') {
            MuneemDialogs.showChangePasswordDialog(context, controller);
          } else if (value == 'logout') {
            controller.logOut();
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: 'password',
              child: Row(
                children: [
                  Icon(Icons.password, size: 18, color: Colors.grey.shade600),
                  SizedBox(width: 12.w),
                  Text(AppStrings.changePassword),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 18, color: Colors.red),
                  SizedBox(width: 12.w),
                  Text(
                    AppStrings.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    ];
  }

  Widget _buildFlexibleContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: User info
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22.r,
              child: Obx(() => Text(
                    controller.user.value.name.isNotEmpty
                        ? controller.user.value.name[0].toUpperCase()
                        : 'M',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  )),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                        '${AppStrings.welcome}, ${controller.user.value.name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(height: 2.h),
                  Obx(() => Text(
                        controller.hostelName.value,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        // Second row: Stats
        Row(
          children: [
            _buildAppBarChip(
              Icons.calendar_today,
              DateFormat('dd MMM yyyy').format(DateTime.now()),
            ),
            SizedBox(width: 8.w),
            Obx(() => _buildAppBarChip(
                  Icons.people,
                  '${controller.presentStudentCount.value} ${AppStrings.studentsPresent}',
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
