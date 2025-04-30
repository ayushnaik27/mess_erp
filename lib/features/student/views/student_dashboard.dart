import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/services/user_service.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/student/controllers/student_dashboard_controller.dart';
import 'package:mess_erp/features/student/models/announcement_model.dart';
import 'package:mess_erp/features/student/services/announcement_service.dart';
import 'package:mess_erp/features/student/widgets/meal_preview_slider.dart';
import 'package:mess_erp/providers/hash_helper.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const String routeName = '/student-dashboard';
  final String? rollNumber;

  const StudentDashboardScreen({super.key, this.rollNumber});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final StudentDashboardController _controller =
      Get.find<StudentDashboardController>();
  final AnnouncementService _announcementService = AnnouncementService();
  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _announcementService.deleteOldAnnouncements();
    _controller.checkMealStatus();
    _controller.initializeUser(widget.rollNumber);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Obx(() {
      final user = UserService.to.currentUser.value;

      if (user == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: _buildAppBar(user),
        drawer: _buildDrawer(user),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await _controller.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Welcome section with hostel ID
                    _buildWelcomeSection(user),

                    SizedBox(height: 24.h),

                    // Quick actions
                    _buildQuickActions(user.hostelId),

                    SizedBox(height: 24.h),

                    // Announcements
                    _buildAnnouncementsSection(),

                    SizedBox(height: 24.h),

                    // Features grid
                    _buildFeaturesGrid(user),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar(User user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leadingWidth: 48.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          splashRadius: 28.r,
          constraints: BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ),
      titleSpacing: 0,
      title: Text(
        'Student Dashboard',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
      toolbarHeight: 72.h,
      actions: [
        // QR Code scanner button with Obx wrapper
        Obx(
          () => _controller.isMealLive.value
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: IconButton(
                    onPressed: () => _controller.navigateToQrScanner(user.id),
                    icon: const Icon(Icons.qr_code_scanner,
                        color: AppColors.primary),
                    tooltip: 'Scan QR for Meal',
                    splashRadius: 24.r,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 12.h, 16.w, 12.h),
          child: GestureDetector(
            onTap: () {
              Get.bottomSheet(
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: AppColors.primary),
                        title: Text('My Profile',
                            style: TextStyle(fontSize: 16.sp)),
                        onTap: () {
                          Get.back();
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.lock_outline, color: AppColors.primary),
                        title: Text('Change Password',
                            style: TextStyle(fontSize: 16.sp)),
                        onTap: () {
                          Get.back();
                          _showChangePasswordDialog(user.id);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: AppColors.error),
                        title: Text('Logout',
                            style: TextStyle(
                                fontSize: 16.sp, color: AppColors.error)),
                        onTap: () {
                          Get.back();
                          _controller.logout();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ), // Status bar style
    );
  }

  Widget _buildWelcomeSection(User user) {
    final now = DateTime.now();
    String greeting;
    String timeOfDay;

    if (now.hour < 12) {
      greeting = 'Good morning';
      timeOfDay = 'morning';
    } else if (now.hour < 17) {
      greeting = 'Good afternoon';
      timeOfDay = 'afternoon';
    } else {
      greeting = 'Good evening';
      timeOfDay = 'evening';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTimeIcon(timeOfDay),
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _capitalize(user.name),
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 16.h),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   physics: BouncingScrollPhysics(),
                    //   child: Row(
                    //     children: [
                    //       _buildInfoBadge(
                    //         icon: Icons.badge_outlined,
                    //         label: user.id,
                    //         isPrimary: false,
                    //       ),

                    //       SizedBox(width: 10.w),

                    //       _buildInfoBadge(
                    //         icon: Icons.apartment,
                    //         label: 'Hostel ${user.hostelId}',
                    //         isPrimary: false,
                    //       ),

                    //       SizedBox(width: 10.w),

                    //       // Current date badge
                    //       _buildInfoBadge(
                    //         icon: Icons.calendar_today,
                    //         label: DateFormat('MMM d, yyyy')
                    //             .format(DateTime.now()),
                    //         isPrimary: false,
                    //       ),
                    //     ],
                    //   ),
                    // ).animate().fadeIn(
                    //       duration: 800.ms,
                    //       delay: 100.ms,
                    //     ),
                  ],
                ),
              ),

              // Divider with improved styling
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(10.h, 0.h, 10.h, 16.h),
                child: MealPreviewSlider(hostelId: user.hostelId),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutQuad,
          duration: 700.ms,
        );
  }

  // // Helper method for info badges
  // Widget _buildInfoBadge(
  //     {required IconData icon,
  //     required String label,
  //     required bool isPrimary}) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //     decoration: BoxDecoration(
  //       color: isPrimary ? AppColors.primary.withOpacity(0.08) : Colors.white,
  //       borderRadius: BorderRadius.circular(30.r),
  //       border: Border.all(
  //         color: isPrimary
  //             ? AppColors.primary.withOpacity(0.2)
  //             : Colors.grey.shade200,
  //         width: 1,
  //       ),
  //       boxShadow: [
  //         if (isPrimary)
  //           BoxShadow(
  //             color: AppColors.primary.withOpacity(0.15),
  //             blurRadius: 8,
  //             offset: Offset(0, 2),
  //           )
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           icon,
  //           size: 16.sp,
  //           color: isPrimary ? AppColors.primary : Colors.grey.shade600,
  //         ),
  //         SizedBox(width: 6.w),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 13.sp,
  //             fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
  //             color: isPrimary ? AppColors.primary : AppColors.textSecondary,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Get an appropriate icon based on time of day
  IconData _getTimeIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return Icons.wb_sunny_outlined;
      case 'afternoon':
        return Icons.wb_cloudy_outlined;
      case 'evening':
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }

  Widget _buildQuickActions(String hostelId) {
    return Obx(() => Row(
          children: [
            _buildActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan QR',
              onTap: () => _controller.navigateToQrScanner(
                  Provider.of<UserProvider>(context, listen: false)
                      .user
                      .username),
              isActive: _controller.isMealLive.value,
            ),
            SizedBox(width: 12.w),

            // TODO: implement this latter
            _buildActionButton(
              icon: Icons.restaurant_menu,
              label: 'Mess Menu',
              onTap: () => _controller.navigateToMessMenu(hostelId),
            ),
            SizedBox(width: 12.w),
            _buildActionButton(
              icon: Icons.receipt_long,
              label: 'Mess Bill',
              onTap: () => _controller.navigateToMessBill(
                  Provider.of<UserProvider>(context, listen: false)
                      .user
                      .username),
            ),
          ],
        ));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.inactive,
                  size: 24.r,
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.3,
          end: 0,
          curve: Curves.easeOutQuad,
          duration: 600.ms,
        );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Announcements',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all announcements
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 700.ms),
        SizedBox(height: 12.h),
        StreamBuilder<List<Announcement>>(
          stream: _announcementService.getAnnouncements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 100.h,
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              _logger.e('Error loading announcements', error: snapshot.error);
              return _buildErrorWidget('Unable to load announcements');
            } else {
              List<Announcement> announcements = snapshot.data ?? [];

              if (announcements.isEmpty) {
                return _buildEmptyWidget('No announcements available');
              }

              return _buildAnnouncementsList(announcements);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList(List<Announcement> announcements) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: announcements.length > 3 ? 3 : announcements.length,
        separatorBuilder: (context, index) => Divider(
          color: AppColors.divider,
          height: 1,
          indent: 16.w,
          endIndent: 16.w,
        ),
        itemBuilder: (context, index) {
          return _buildAnnouncementItem(announcements[index], index);
        },
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOutQuad,
          duration: 800.ms,
        );
  }

  Widget _buildAnnouncementItem(Announcement announcement, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Icon(
                _getAnnouncementIcon(announcement.title),
                color: AppColors.primary,
                size: 20.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  announcement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  announcement.timestamp != null
                      ? DateFormat('dd MMM, yyyy • h:mm a')
                          .format(announcement.timestamp!.toDate())
                      : 'Just now',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        bool openBill = announcement.title.toLowerCase() == 'mess bill';

        if (announcement.file != null) {
          _announcementService.openAnnouncement(
            announcement.file!.path,
            openBill: openBill,
          );
        }
      },
    ).animate().fadeIn(
          duration: 800.ms,
          delay: Duration(milliseconds: 100 * index),
        );
  }

  IconData _getAnnouncementIcon(String title) {
    title = title.toLowerCase();
    if (title.contains('mess bill')) return Icons.receipt_long;
    if (title.contains('menu')) return Icons.restaurant_menu;
    if (title.contains('leave')) return Icons.event_available;
    if (title.contains('holiday')) return Icons.celebration;
    if (title.contains('maintenance')) return Icons.build;
    if (title.contains('important')) return Icons.priority_high;
    return Icons.campaign;
  }

  Widget _buildFeaturesGrid(User user) {
    final features = [
      {
        'title': 'Request\nExtra Items',
        'icon': Icons.add_shopping_cart,
        'onTap': () => _controller.navigateToRequestExtraItems(user.id),
      },
      {
        'title': 'Apply for\nLeave',
        'icon': Icons.event_available,
        'onTap': () => _controller.navigateToApplyLeave(user.id),
      },
      {
        'title': 'Track\nLeaves',
        'icon': Icons.calendar_today,
        'onTap': () => _controller.navigateToTrackLeaves(user.id),
      },
      {
        'title': 'File\nGrievance',
        'icon': Icons.report_problem,
        'onTap': () => _controller.navigateToFileGrievance(),
      },
      {
        'title': 'Track\nComplaints',
        'icon': Icons.check_circle,
        'onTap': () => _controller.navigateToTrackComplaints(),
      },
      {
        'title': 'Change\nPassword',
        'icon': Icons.lock,
        'onTap': () => _showChangePasswordDialog(user.id),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 900.ms),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.9,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureItem(
              title: features[index]['title'] as String,
              icon: features[index]['icon'] as IconData,
              onTap: features[index]['onTap'] as VoidCallback,
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 800.ms,
          delay: Duration(milliseconds: 100 * index),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOutQuad,
          duration: 800.ms,
          delay: Duration(milliseconds: 100 * index),
        );
  }

  Widget _buildDrawer(User user) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30.r,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  _capitalize(user.name),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      user.id,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Hostel ${user.hostelId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            onTap: () {
              Get.back();
              _controller.navigateToQrScanner(user.id);
            },
            isVisible: _controller.isMealLive.value,
          ),
          _buildDrawerItem(
            icon: Icons.restaurant_menu,
            title: 'View Mess Menu',
            onTap: () {
              Get.back();
              // MessMenuService.viewMessMenu();
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long,
            title: 'View Mess Bill',
            onTap: () {
              Get.back();
              _controller.navigateToMessBill(user.id);
            },
          ),
          _buildDrawerItem(
            icon: Icons.add_shopping_cart,
            title: 'Request Extra Items',
            onTap: () {
              Get.back();
              _controller.navigateToRequestExtraItems(user.id);
            },
          ),
          _buildDrawerItem(
            icon: Icons.event_available,
            title: 'Apply for Leave',
            onTap: () {
              Get.back();
              _controller.navigateToApplyLeave(user.id);
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: 'Track Leaves',
            onTap: () {
              Get.back();
              _controller.navigateToTrackLeaves(user.id);
            },
          ),
          _buildDrawerItem(
            icon: Icons.report_problem,
            title: 'File Grievance',
            onTap: () {
              Get.back();
              _controller.navigateToFileGrievance();
            },
          ),
          _buildDrawerItem(
            icon: Icons.check_circle,
            title: 'Track Complaints',
            onTap: () {
              Get.back();
              _controller.navigateToTrackComplaints();
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () {
              Get.back();
              _showChangePasswordDialog(user.id);
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () => _controller.logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isVisible = true,
  }) {
    if (!isVisible) return const SizedBox();

    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 22.r,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
    );
  }

  void _showChangePasswordDialog(String rollNumber) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (passwordController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Password cannot be empty',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.error.withOpacity(0.9),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    Get.snackbar(
                      'Error',
                      'Passwords do not match',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.error.withOpacity(0.9),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  _changePassword(rollNumber, passwordController.text);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changePassword(String rollNumber, String newPassword) async {
    try {
      String hashedPassword = HashHelper.encode(newPassword);
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.student)
          .doc(rollNumber)
          .update({
        FirestoreConstants.password: hashedPassword,
      });

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      _logger.e('Error changing password', error: e);
      Get.snackbar(
        'Error',
        'Failed to change password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 40.r,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              color: AppColors.textTertiary,
              size: 40.r,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty
      ? s
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ')
      : '';
}
