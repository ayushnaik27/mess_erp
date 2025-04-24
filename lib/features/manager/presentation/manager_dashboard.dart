import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/manager/controllers/manager_dashboard_controller.dart';
import 'package:mess_erp/muneem/netx_three_meals_screen.dart';
import 'package:mess_erp/widgets/change_password_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class ManagerDashboardScreen extends GetView<ManagerDashboardController> {
  static const routeName = '/managerDashboard';

  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Obx(() => controller.isLoading.value
          ? _buildLoadingState()
          : _buildDashboard()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Obx(() {
        final user = controller.currentUser.value;
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              radius: 20.r,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'M',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  controller.capitalize(user?.name ?? 'Manager'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(24.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          alignment: Alignment.centerLeft,
          child: Obx(() => Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    controller.hostelName.value.isNotEmpty
                        ? controller.hostelName.value
                        : 'Hostel ${controller.hostelId.value}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_outlined, color: Colors.black87),
          onPressed: controller.loadDashboardData,
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.black87),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Change Password'),
              onTap: () {
                // Using addPostFrameCallback to avoid the "looking-for-an-ancestor-renderobject" error
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) => ChangePasswordDialog(
                      changePassword: controller.changePassword,
                    ),
                  );
                });
              },
            ),
            PopupMenuItem(
              child: Text('Logout'),
              onTap: () {
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/loading.png', // Add a loading image to your assets
            width: 120.w,
            height: 120.h,
          ),
          SizedBox(height: 24.h),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading dashboard data...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () => controller.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKeyMetrics(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Quick Actions'),
            SizedBox(height: 16.h),
            _buildQuickActions(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Recent Activity'),
            SizedBox(height: 16.h),
            _buildRecentActivity(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Financial Overview'),
            SizedBox(height: 16.h),
            _buildFinancialOverview(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Current Inventory'),
            SizedBox(height: 16.h),
            _buildInventoryOverview(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      children: [
        // Main Stock Value Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Inventory Value',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      // Show inventory info
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(() => Text(
                    '₹${NumberFormat('#,##,###').format(controller.stockValue.value)}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  )),
              SizedBox(height: 20.h),
              OutlinedButton(
                onPressed: () => Get.toNamed('/issueStock'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Inventory Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 18.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Metrics Cards Row
        Row(
          children: [
            Obx(() => _buildMetricCard(
                  title: 'Grievances',
                  value: controller.totalGrievances.value.toString(),
                  icon: Icons.report_problem_outlined,
                  color: Colors.orange.shade700,
                  onTap: () {
                    Get.to(() =>
                        const AssignedGrievancesScreen(userType: 'manager'));
                  },
                )),
            SizedBox(width: 12.w),
            Obx(() => _buildMetricCard(
                  title: 'Vouchers',
                  value: controller.pendingVouchers.value.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: Colors.purple.shade700,
                  onTap: () {
                    Get.toNamed('/previousVouchers');
                  },
                )),
            SizedBox(width: 12.w),
            Obx(() => _buildMetricCard(
                  title: 'Stock Items',
                  value: controller.stockItems.value.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  onTap: () {
                    Get.toNamed('/issueStock');
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Generate Voucher',
            subtitle: 'Create payment vouchers',
            icon: Icons.receipt_outlined,
            color: AppColors.primary,
            onTap: () => Get.toNamed(AppRoutes.generateVoucher),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Receive Stock',
            subtitle: 'Add new stock items',
            icon: Icons.add_box_outlined,
            color: Colors.teal,
            onTap: () => Get.toNamed('/receiveStock'),
          ),
        ),
        // Apply the same height increase to all remaining tiles
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Issue Stock',
            subtitle: 'Release inventory items',
            icon: Icons.outbox_outlined,
            color: Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.issueStock),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Track Bills',
            subtitle: 'Monitor student bills',
            icon: Icons.receipt_long_outlined,
            color: Colors.purple,
            onTap: () => {},
            // onTap: () => Get.to(() => TrackBillsScreen()),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Next Meals',
            subtitle: 'View upcoming meals',
            icon: Icons.restaurant_menu_outlined,
            color: Colors.indigo,
            onTap: () => Get.to(() => NextThreeMealsScreen()),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2,
          child: _buildActionTile(
            title: 'Grievances',
            subtitle: 'Manage student grievances',
            icon: Icons.support_agent_outlined,
            color: Colors.red.shade700,
            onTap: () => Get.to(
                () => const AssignedGrievancesScreen(userType: 'manager')),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
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
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
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
      child: Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.recentTransactions.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = controller.recentTransactions[index];
              final isExpense = transaction['type'] == 'expense';

              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isExpense
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isExpense ? Colors.red : Colors.green,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  transaction['title'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(transaction['date']),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: Text(
                  '${isExpense ? '-' : '+'}₹${NumberFormat('#,##,###').format(transaction['amount'])}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildFinancialOverview() {
    return Obx(() {
      final totalBudget = controller.totalBudget.value;
      final totalSpent = controller.totalSpent.value;
      final percentSpent = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

      return Container(
        padding: EdgeInsets.all(20.w),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${NumberFormat('#,##,###').format(totalBudget)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${NumberFormat('#,##,###').format(totalSpent)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 16.h,
              animationDuration: 1500,
              percent: percentSpent > 1.0 ? 1.0 : percentSpent,
              center: Text(
                '${(percentSpent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              barRadius: Radius.circular(8.r),
              progressColor:
                  percentSpent > 0.8 ? Colors.red : AppColors.primary,
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFinancialMetric(
                  label: 'Bills Collected',
                  value:
                      '₹${NumberFormat('#,##,###').format(controller.billsCollected.value)}',
                  color: Colors.green,
                ),
                _buildFinancialMetric(
                  label: 'Bills Pending',
                  value:
                      '₹${NumberFormat('#,##,###').format(controller.billsPending.value)}',
                  color: Colors.orange,
                ),
                _buildFinancialMetric(
                  label: 'Savings',
                  value:
                      '₹${NumberFormat('#,##,###').format(controller.savings.value)}',
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinancialMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryOverview() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ITEMS BY CATEGORY',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/issueStock'),
                child: Text(
                  'Manage Stock',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.5,
                ),
                itemCount: controller.inventoryCategories.length,
                itemBuilder: (context, index) {
                  final category = controller.inventoryCategories[index];

                  Color categoryColor = _getColorFromString(category['color']);
                  IconData categoryIcon = _getIconFromString(category['icon']);

                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categoryIcon,
                                color: categoryColor,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              category['count'].toString(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  // Helper method to convert string to color
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'amber':
        return Colors.amber;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'deepOrange':
        return Colors.deepOrange;
      default:
        return AppColors.primary;
    }
  }

  // Helper method to convert string to icon
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'grain':
        return Icons.grain;
      case 'eco':
        return Icons.eco;
      case 'egg_alt':
        return Icons.egg_alt;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isSelected: true,
              ),
              _buildNavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                isSelected: false,
                onTap: () => Get.toNamed('/issueStock'),
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Finance',
                isSelected: false,
                onTap: () => Get.toNamed('/generateVoucher'),
              ),
              _buildNavItem(
                icon: Icons.support_agent_outlined,
                label: 'Grievances',
                isSelected: false,
                onTap: () => Get.to(
                    () => const AssignedGrievancesScreen(userType: 'manager')),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey.shade600,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
