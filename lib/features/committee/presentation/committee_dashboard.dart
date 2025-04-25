import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/widgets/loading_view.dart';
import 'package:mess_erp/features/committee/controllers/committee_dashboard_controller.dart';
import 'package:mess_erp/features/committee/presentation/widgets/announcements_section.dart';
import 'package:mess_erp/features/committee/presentation/widgets/committee_app_bar.dart';
import 'package:mess_erp/features/committee/presentation/widgets/dashboard_stats_card.dart';
import 'package:mess_erp/features/committee/presentation/widgets/feature_card.dart';

class CommitteeDashboardScreen extends StatelessWidget {
  static const routeName = '/committeeDashboard';

  const CommitteeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommitteeDashboardController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView(message: 'Loading dashboard...');
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80.sp,
                  color: Colors.red.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: controller.refreshDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Get.theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            CommitteeAppBar(
              controller: controller,
              innerBoxIsScrolled: innerBoxIsScrolled,
            ),
          ],
          body: RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            child: _buildDashboardContent(context, controller),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/addAnnouncement'),
        backgroundColor: Get.theme.colorScheme.primary,
        tooltip: 'Add Announcement',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    CommitteeDashboardController controller,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // Stats Section
          Row(
            children: [
              Expanded(
                child: DashboardStatsCard(
                  title: 'Students',
                  value: '${controller.totalStudentsCount}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: DashboardStatsCard(
                  title: 'Pending Grievances',
                  value: '${controller.pendingGrievancesCount}',
                  icon: Icons.assignment_late,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: DashboardStatsCard(
                  title: 'Announcements',
                  value: '${controller.totalAnnouncementsCount}',
                  icon: Icons.campaign,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: DashboardStatsCard(
                  title: 'Total Bills',
                  value:
                      '₹${NumberFormat('#,##,###').format(controller.totalBillAmount.value.round())}',
                  icon: Icons.receipt_long,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Announcements Section
          Text(
            'Announcements',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          AnnouncementsSection(controller: controller),

          SizedBox(height: 24.h),

          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          _buildFeaturesGrid(context, controller),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(
    BuildContext context,
    CommitteeDashboardController controller,
  ) {
    final List<Map<String, dynamic>> features = [
      {
        'title': AppStrings.messMenu,
        'subtitle': AppStrings.viewOrUpdateMenu,
        'icon': Icons.restaurant_menu,
        'gradient': [AppColors.info, AppColors.info.withOpacity(0.7)],
        'onTap': controller.viewMessMenu,
        'isLarge': true,
      },
      // {
      //   'title': AppStrings.uploadMessMenu,
      //   'subtitle': AppStrings.shareNewMenuWithStudents,
      //   'icon': Icons.upload_file,
      //   'gradient': [AppColors.success, AppColors.success.withOpacity(0.7)],
      //   'onTap': () async {
      //     final uploaded = await controller.uploadMessMenu();
      //     if (uploaded) {
      //       Get.snackbar(
      //         AppStrings.success,
      //         AppStrings.messMenuUploaded,
      //         snackPosition: SnackPosition.BOTTOM,
      //         backgroundColor: AppColors.success,
      //         colorText: Colors.white,
      //       );
      //     }
      //   },
      // },
      {
        'title': AppStrings.billsAndPayments,
        'subtitle': AppStrings.manageFinancialTransactions,
        'icon': Icons.receipt,
        'gradient': [Color(0xFF9C27B0), Color(0xFFCE93D8)],
        'onTap': () => Get.toNamed('/billsScreen'),
      },
      {
        'title': AppStrings.extraItems,
        'subtitle': AppStrings.manageAdditionalFoodItems,
        'icon': Icons.shopping_basket,
        'gradient': [AppColors.warning, AppColors.warning.withOpacity(0.7)],
        'onTap': () => Get.toNamed('/extraItems'),
      },
      {
        'title': AppStrings.previousVouchers,
        'subtitle': AppStrings.viewPreviousExpenditureRecords,
        'icon': Icons.receipt_long,
        'gradient': [Color(0xFF3949AB), Color(0xFF9FA8DA)],
        'onTap': () => Get.toNamed('/previousVouchers'),
      },
      {
        'title': AppStrings.viewGrievances,
        'subtitle': AppStrings.addressStudentComplaints,
        'icon': Icons.assignment_turned_in,
        'gradient': [AppColors.error, AppColors.error.withOpacity(0.7)],
        'onTap': () => Get.toNamed('/viewAllGrievances'),
        'badge': controller.pendingGrievancesCount.value > 0
            ? '${controller.pendingGrievancesCount.value}'
            : null,
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120.h,
          child: FeatureCard(
            title: features[0]['title'],
            subtitle: features[0]['subtitle'],
            icon: features[0]['icon'],
            gradientColors: features[0]['gradient'],
            onTap: features[0]['onTap'],
            badge: features[0]['badge'],
            isLarge: true,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length - 1,
          itemBuilder: (context, index) {
            final feature = features[index + 1];
            return FeatureCard(
              title: feature['title'],
              subtitle: feature['subtitle'],
              icon: feature['icon'],
              gradientColors: feature['gradient'],
              onTap: feature['onTap'],
              badge: feature['badge'],
            );
          },
        ),
      ],
    );
  }
}
