import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/features/committee/controllers/committee_dashboard_controller.dart';
import 'package:mess_erp/features/committee/presentation/widgets/password_dialog.dart';

class CommitteeAppBar extends StatelessWidget {
  final CommitteeDashboardController controller;
  final bool innerBoxIsScrolled;

  const CommitteeAppBar({
    super.key,
    required this.controller,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 190.h,
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: Get.theme.colorScheme.primary,
      title: Text(
        AppStrings.committeeDashboard,
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
                Get.theme.colorScheme.primary,
                Get.theme.colorScheme.primary.withOpacity(0.85),
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
                top: kToolbarHeight + 16.h,
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
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (value) {
          if (value == 'password') {
            showDialog(
              context: context,
              builder: (context) => PasswordDialog(
                onChangePassword: controller.changePassword,
              ),
            );
          } else if (value == 'logout') {
            // Handle logout
            Get.offAllNamed('/login');
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24.r,
              child: Obx(() => Text(
                    controller.user.value.name.isNotEmpty
                        ? controller.user.value.name[0].toUpperCase()
                        : 'C',
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
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
                        controller.user.value.name.isNotEmpty
                            ? '${AppStrings.welcome}, ${controller.capitalize(controller.user.value.name)}'
                            : AppStrings.welcomeCommittee,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                        controller.user.value.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                DateTime.now().day == 1
                    ? 'New month started today'
                    : 'Day ${DateTime.now().day} of current month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
