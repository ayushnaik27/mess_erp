import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/clerk/controllers/clerk_dashboard_controller.dart';
import 'package:mess_erp/features/clerk/views/dialogs/add_committee_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/add_manager_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/add_muneem_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/add_student_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/add_vendor_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/change_password_dialog.dart';
import 'package:mess_erp/features/clerk/views/dialogs/impose_fine_dialog.dart';

class ClerkDashboardScreen extends GetView<ClerkDashboardController> {
  const ClerkDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              SliverToBoxAdapter(child: _buildSectionHeader("User Management")),
              SliverToBoxAdapter(child: _buildUserManagementSection(context)),
              SliverToBoxAdapter(
                  child: _buildSectionHeader("Tender & Enrollment")),
              SliverToBoxAdapter(child: _buildTenderSection(context)),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppStrings.clerkDashboard,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Text(
                    controller.username.value.isEmpty
                        ? 'A'
                        : controller.username.value[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    SizedBox(height: 4.h),
                    Text(
                      controller.currentUser.value.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1, end: 0),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showChangePasswordDialog(context),
                icon: Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              ),
            ],
          ),
        ]));
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.payment,
                  title: AppStrings.imposeFine,
                  color: AppColors.error,
                  onTap: () => _showImposeFineDialog(context),
                ),
                _buildVerticalDivider(),
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.app_registration,
                  title: AppStrings.enrollmentRequests,
                  color: AppColors.info,
                  onTap: controller.navigateToEnrollmentRequests,
                ),
                _buildVerticalDivider(),
                _buildQuickActionItem(
                  context: context,
                  icon: Icons.add_business,
                  title: AppStrings.openTender,
                  color: AppColors.success,
                  onTap: controller.navigateToOpenTender,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 50.h,
      width: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h, bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildUserManagementSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildManagementTile(
                context: context,
                icon: Icons.person_add,
                title: AppStrings.addStudent,
                subtitle: 'Create new student accounts',
                color: AppColors.success,
                onTap: () => _showAddStudentDialog(context),
              ),
              Divider(
                  height: 24.h,
                  thickness: 1,
                  color: AppColors.divider.withOpacity(0.5)),
              _buildManagementTile(
                context: context,
                icon: Icons.people,
                title: AppStrings.addManager,
                subtitle: 'Create new manager accounts',
                color: AppColors.tertiary,
                onTap: () => _showAddManagerDialog(context),
              ),
              Divider(
                  height: 24.h,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.1)),
              _buildManagementTile(
                context: context,
                icon: Icons.people_alt,
                title: 'Add Muneem',
                subtitle: 'Create new muneem accounts',
                color: const Color(0xFF26A69A),
                onTap: () => _showAddMuneemDialog(context),
              ),
              Divider(
                  height: 24.h,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.1)),
              _buildManagementTile(
                context: context,
                icon: Icons.group_add,
                title: 'Add Committee Member',
                subtitle: 'Create new committee member accounts',
                color: const Color(0xFFFFB300),
                onTap: () => _showAddCommitteeDialog(context),
              ),
              Divider(
                  height: 24.h,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.1)),
              _buildManagementTile(
                context: context,
                icon: Icons.person_add_alt_1,
                title: 'Add Vendor',
                subtitle: 'Create new vendor accounts',
                color: const Color(0xFFEC407A),
                onTap: () => _showAddVendorDialog(context),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildManagementTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.inactive,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTenderCard(
                  title: 'View All Tenders',
                  icon: Icons.visibility,
                  color: const Color(0xFF78909C),
                  onTap: controller.navigateToAllTenders,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTenderCard(
                  title: 'View Grievances',
                  icon: Icons.question_answer,
                  color: const Color(0xFF8D6E63),
                  onTap: controller.navigateToAssignedGrievances,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildReportCard(
            title: 'Generate Monthly Report',
            subtitle: 'Create and view financial reports',
            icon: Icons.insights,
            onTap: controller.navigateToMonthlyReports,
          ),
        ],
      ),
    );
  }

  Widget _buildTenderCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF42A5F5),
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16.sp,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 1100.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30.r,
                          child: Text(
                            controller.username.value.isEmpty
                                ? 'A'
                                : controller.username.value[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.currentUser.value.name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                controller.username.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Clerk',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          _buildDrawerTile(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Get.back(),
          ),
          _buildDrawerTile(
            icon: Icons.insights,
            title: AppStrings.generateMonthlyReport,
            onTap: () {
              Get.back();
              controller.navigateToMonthlyReports();
            },
          ),
          _buildDrawerTile(
            icon: Icons.open_in_new,
            title: AppStrings.openTender,
            onTap: () {
              Get.back();
              controller.navigateToOpenTender();
            },
          ),
          _buildDrawerTile(
            icon: Icons.list_alt,
            title: AppStrings.viewAllTenders,
            onTap: () {
              Get.back();
              controller.navigateToAllTenders();
            },
          ),
          _buildDrawerTile(
            icon: Icons.app_registration,
            title: AppStrings.enrollmentRequests,
            onTap: () {
              Get.back();
              controller.navigateToEnrollmentRequests();
            },
          ),
          _buildDrawerTile(
            icon: Icons.question_answer,
            title: AppStrings.viewAssignedGrievances,
            onTap: () {
              Get.back();
              controller.navigateToAssignedGrievances();
            },
          ),
          const Divider(),
          _buildDrawerTile(
            icon: Icons.lock,
            title: AppStrings.changePassword,
            onTap: () {
              Get.back();
              _showChangePasswordDialog(context);
            },
          ),
          _buildDrawerTile(
            icon: Icons.logout,
            title: AppStrings.logout,
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onChangePassword: (newPassword) async {
          final success = await controller.changePassword(newPassword);
          Get.back();
          if (success) {
            Get.snackbar(
              AppStrings.success,
              AppStrings.passwordChangedSuccess,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              AppStrings.errorTitle,
              AppStrings.passwordChangeFailed,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(),
    );
  }

  void _showAddVendorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddVendorDialog(),
    );
  }

  void _showImposeFineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImposeFineDialog(),
    );
  }

  void _showAddManagerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddManagerDialog(),
    );
  }

  void _showAddMuneemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMuneemDialog(),
    );
  }

  void _showAddCommitteeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCommitteeDialog(),
    );
  }
}
