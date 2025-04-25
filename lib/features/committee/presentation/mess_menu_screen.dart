import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/widgets/loading_view.dart';
import 'package:mess_erp/features/committee/controllers/mess_menu_controller.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:mess_erp/features/committee/presentation/widgets/meal_card.dart';

class MessMenuScreen extends StatelessWidget {
  static const routeName = '/messMenu';

  const MessMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessMenuController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView(message: 'Loading mess menu...');
        }

        if (controller.hasError.value) {
          return _buildErrorState(controller);
        }

        if (controller.weeklyMenu.value == null) {
          return _buildEmptyState(controller);
        }

        return _buildMenuScreenContent(context, controller);
      }),
    );
  }

  Widget _buildErrorState(MessMenuController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Could not load menu',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: controller.fetchWeeklyMenu,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Widget _buildEmptyState(MessMenuController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 60.sp,
            color: AppColors.primary.withOpacity(0.7),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Menu Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'No menu data is available for this hostel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: controller.createDefaultWeeklyMenu,
            icon: Icon(Icons.add),
            label: Text('Create Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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

  Widget _buildMenuScreenContent(
      BuildContext context, MessMenuController controller) {
    return Column(
      children: [
        _buildAppBar(context, controller),
        _buildDaySelector(context, controller),
        Expanded(
          child: Obx(() {
            final selectedDayId = controller.selectedDayId.value;
            if (selectedDayId.isEmpty || controller.weeklyMenu.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month,
                        size: 60.sp, color: AppColors.primary.withOpacity(0.5)),
                    SizedBox(height: 16.h),
                    Text('Select a day to view the menu',
                        style: TextStyle(
                            fontSize: 16.sp, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            final dayIndex = controller.weeklyMenu.value!.days
                .indexWhere((day) => day.id == selectedDayId);

            if (dayIndex == -1) {
              return Center(child: Text('Day not found'));
            }

            final day = controller.weeklyMenu.value!.days[dayIndex];
            return _buildDayContent(context, controller, day);
          }),
        ),
      ],
    );
  }

  Widget _buildDayContent(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: day.meals.length,
      itemBuilder: (context, index) {
        final meal = day.meals[index];
        return MealCard(
          meal: meal,
          day: day,
          controller: controller,
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, MessMenuController controller) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 16.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.messMenu,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Obx(() => Text(
                              'Hostel ${controller.hostelId.value}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Save button
                  Container(
                    height: 36.h,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showSaveConfirmationDialog(context, controller),
                      icon: Icon(Icons.save, size: 16.sp),
                      label: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Month and date display
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          DateFormat("MMMM yyyy").format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Weekly Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(
      BuildContext context, MessMenuController controller) {
    return Container(
      height: 95.h,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 4.h),
            child: Text(
              'SELECT DAY',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // New implementation with separate Obx for each day card
          Expanded(
            child: controller.weeklyMenu.value == null
                ? SizedBox.shrink()
                : _buildDayCardsList(context, controller),
          ),

          // Bottom divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  // Separated day cards list for better organization
  Widget _buildDayCardsList(
      BuildContext context, MessMenuController controller) {
    final today = DateTime.now().weekday - 1; // 0-6 for Monday-Sunday

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      physics: BouncingScrollPhysics(),
      itemCount: controller.weeklyMenu.value!.days.length,
      itemBuilder: (context, index) {
        final day = controller.weeklyMenu.value!.days[index];
        final isToday = index == today;

        // Each card wrapped in its own Obx for individual reactivity
        return Obx(() {
          final isSelected = controller.selectedDayId.value == day.id;
          final baseColor = day.isWeekend
              ? Color(0xFFF06292) // Weekend color
              : AppColors.primary;

          return _buildDayCard(
              context, controller, day, isSelected, isToday, baseColor);
        });
      },
    );
  }

  // Separate widget for each day card for clean code
  Widget _buildDayCard(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
    bool isSelected,
    bool isToday,
    Color baseColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // More explicit update handling
            if (controller.selectedDayId.value != day.id) {
              controller.selectedDayId.value = day.id;
              controller.update(); // Force update
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          splashColor: baseColor.withOpacity(0.3),
          highlightColor: baseColor.withOpacity(0.2),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  isSelected ? baseColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? baseColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              // Add subtle shadow for selected state
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 72.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day name (e.g., MON)
                  Text(
                    day.name.substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? baseColor : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveConfirmationDialog(
    BuildContext context,
    MessMenuController controller,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.save,
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Save Menu',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This will save all changes and publish the menu to students. Are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      AppStrings.cancel,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.saveWeeklyMenu();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Save & Publish',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
