import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/manager/track_bills_screen.dart';
import 'package:mess_erp/widgets/change_password_dialog.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

import '../muneem/netx_three_meals_screen.dart';
import '../providers/hash_helper.dart';
import '../providers/user_provider.dart';

class ManagerDashboardScreen extends StatefulWidget {
  static const routeName = '/managerDashboard';

  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isLoading = true;
  int _totalGrievances = 0;
  int _pendingVouchers = 0;
  int _stockItems = 0;
  double _stockValue = 0;

  // Mock data for demonstration - replace with real data from Firestore
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'title': 'Rice purchase',
      'date': DateTime.now().subtract(Duration(days: 1)),
      'amount': 12500.0,
      'type': 'expense'
    },
    {
      'title': 'Vegetables delivery',
      'date': DateTime.now().subtract(Duration(days: 2)),
      'amount': 3800.0,
      'type': 'expense'
    },
    {
      'title': 'Bill payments received',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'amount': 25000.0,
      'type': 'income'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final grievancesSnapshot = await FirebaseFirestore.instance
          .collection('grievances')
          .where('assignedTo', isEqualTo: 'manager')
          .get();

      final vouchersSnapshot = await FirebaseFirestore.instance
          .collection('vouchers')
          .where('status', isEqualTo: 'pending')
          .get();

      final stockSnapshot =
          await FirebaseFirestore.instance.collection('stock').get();

      double totalStockValue = 0;
      for (var doc in stockSnapshot.docs) {
        if (doc.data().containsKey('balance') && doc['balance'] != null) {
          totalStockValue += double.parse(doc['balance'].toString());
        }
      }

      setState(() {
        _totalGrievances = grievancesSnapshot.docs.length;
        _pendingVouchers = vouchersSnapshot.docs.length;
        _stockItems = stockSnapshot.docs.length;
        _stockValue = totalStockValue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      AppLogger().e('Failed to load dashboard data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard data. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void changePassword(String newPassword) async {
    String hashedPassword = HashHelper.encode(newPassword);
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('manager')
        .doc('manager@gmail.com')
        .update({
      'password': hashedPassword,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully!')),
    );
  }

  String capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    MyUser user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: _buildAppBar(user),
      body: _isLoading ? _buildLoadingState() : _buildDashboard(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(MyUser user) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            radius: 20.r,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
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
                capitalize(user.name.isNotEmpty ? user.name : 'Manager'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_outlined, color: Colors.black87),
          onPressed: _loadDashboardData,
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
                      changePassword: changePassword,
                    ),
                  );
                });
              },
            ),
            PopupMenuItem(
              child: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
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
      onRefresh: _loadDashboardData,
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
              Text(
                '₹${NumberFormat('#,##,###').format(_stockValue)}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 20.h),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed('/issueStock'),
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
            _buildMetricCard(
              title: 'Grievances',
              value: _totalGrievances.toString(),
              icon: Icons.report_problem_outlined,
              color: Colors.orange.shade700,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AssignedGrievancesScreen(
                            userType: 'manager')));
              },
            ),
            SizedBox(width: 12.w),
            _buildMetricCard(
              title: 'Vouchers',
              value: _pendingVouchers.toString(),
              icon: Icons.receipt_long_outlined,
              color: Colors.purple.shade700,
              onTap: () {
                Navigator.of(context).pushNamed('/previousVouchers');
              },
            ),
            SizedBox(width: 12.w),
            _buildMetricCard(
              title: 'Stock Items',
              value: _stockItems.toString(),
              icon: Icons.inventory_2_outlined,
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pushNamed('/issueStock');
              },
            ),
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
          mainAxisCellCount: 2.2, // Increased height
          child: _buildActionTile(
            title: 'Generate Voucher',
            subtitle: 'Create payment vouchers',
            icon: Icons.receipt_outlined,
            color: AppColors.primary,
            onTap: () => Navigator.of(context).pushNamed('/generateVoucher'),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2.2, // Increased height
          child: _buildActionTile(
            title: 'Receive Stock',
            subtitle: 'Add new stock items',
            icon: Icons.add_box_outlined,
            color: Colors.teal,
            onTap: () => Navigator.of(context).pushNamed('/receiveStock'),
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
            onTap: () => Navigator.of(context).pushNamed('/issueStock'),
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
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TrackBillsScreen())),
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NextThreeMealsScreen())),
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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const AssignedGrievancesScreen(userType: 'manager'))),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = _recentTransactions[index];
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
      ),
    );
  }

  Widget _buildFinancialOverview() {
    // In a real app, you would calculate these values from your database
    final double totalBudget = 400000;
    final double totalSpent = 285000;
    final double percentSpent = totalSpent / totalBudget;

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
            percent: percentSpent,
            center: Text(
              '${(percentSpent * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            barRadius: Radius.circular(8.r),
            progressColor: percentSpent > 0.8 ? Colors.red : AppColors.primary,
            backgroundColor: Colors.grey.shade200,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinancialMetric(
                label: 'Bills Collected',
                value: '₹145,000',
                color: Colors.green,
              ),
              _buildFinancialMetric(
                label: 'Bills Pending',
                value: '₹38,500',
                color: Colors.orange,
              ),
              _buildFinancialMetric(
                label: 'Savings',
                value: '₹22,500',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
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
    // Sample data for inventory categories
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Grains & Rice',
        'count': 12,
        'icon': Icons.grain,
        'color': Colors.amber
      },
      {
        'name': 'Vegetables',
        'count': 18,
        'icon': Icons.eco,
        'color': Colors.green
      },
      {
        'name': 'Dairy Products',
        'count': 7,
        'icon': Icons.egg_alt,
        'color': Colors.blue
      },
      {
        'name': 'Spices',
        'count': 15,
        'icon': Icons.spa,
        'color': Colors.deepOrange
      },
    ];

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
                onPressed: () => Navigator.of(context).pushNamed('/issueStock'),
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
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: category['color'].withOpacity(0.3),
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
                            color: category['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category['icon'],
                            color: category['color'],
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
          ),
        ],
      ),
    );
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
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Finance',
                isSelected: false,
              ),
              _buildNavItem(
                icon: Icons.support_agent_outlined,
                label: 'Grievances',
                isSelected: false,
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
  }) {
    return InkWell(
      onTap: () {},
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
