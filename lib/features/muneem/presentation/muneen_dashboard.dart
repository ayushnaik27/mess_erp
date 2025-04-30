import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/widgets/loading_view.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/activities_section.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/bottom_navigation.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/dialogs.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/leaves_section.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/meals_section.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/metrics_section.dart';
import 'package:mess_erp/features/muneem/presentation/widgets/muneem_app_bar.dart';

class MuneemDashboardScreen extends GetView<MuneemDashboardController> {
  const MuneemDashboardScreen({Key? key}) : super(key: key);

  static const routeName = '/muneemDashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView(message: 'Loading dashboard...');
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            MuneemAppBar(
              controller: controller,
              innerBoxIsScrolled: innerBoxIsScrolled,
            ),
          ],
          body: _buildDashboardContent(context),
        );
      }),
      bottomNavigationBar: const MuneemBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            MuneemDialogs.showImposeExtraDialog(context, controller),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: AppStrings.imposeExtraAmount,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            MetricsSection(controller: controller),
            SizedBox(height: 20.h),
            _buildSectionTitle(AppStrings.todaysMeals),
            SizedBox(height: 8.h),
            MealsSection(controller: controller),
            SizedBox(height: 20.h),
            _buildSectionTitle(AppStrings.studentsOnLeave),
            SizedBox(height: 8.h),
            LeavesSection(controller: controller),
            SizedBox(height: 20.h),
            _buildSectionTitle(AppStrings.recentActivities),
            SizedBox(height: 8.h),
            ActivitiesSection(controller: controller),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}
