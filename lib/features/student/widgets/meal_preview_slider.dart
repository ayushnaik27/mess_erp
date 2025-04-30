import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/student/services/meal_preview_service.dart';

import '../../committee/models/meal_model.dart';

class MealPreviewSlider extends StatefulWidget {
  final String hostelId;

  const MealPreviewSlider({
    Key? key,
    required this.hostelId,
  }) : super(key: key);

  @override
  State<MealPreviewSlider> createState() => _MealPreviewSliderState();
}

class _MealPreviewSliderState extends State<MealPreviewSlider> {
  final PageController _pageController =
      PageController(initialPage: 1, viewportFraction: 0.85);
  final RxInt _currentPage = 1.obs;
  final MealPreviewService _mealService = Get.put(MealPreviewService());

  @override
  void initState() {
    super.initState();
    _mealService.loadTodayMenu(widget.hostelId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_mealService.isLoading.value) {
        return SizedBox(
          height: 80.h,
          child: Center(
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }

      if (_mealService.todayMenu.value == null) {
        return _buildEmptyState();
      }

      final Meal? previousMeal = _mealService.getPreviousMeal();
      final Meal? currentMeal = _mealService.upcomingMeal.value;
      final Meal? nextMeal = _mealService.getNextMeal();

      final mealsToday = _mealService.todayMenu.value?.meals.length ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Divider and subtle header
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          // Modern header with next meal info
          Padding(
            padding: EdgeInsets.fromLTRB(0, 12.h, 0, 8.h),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu,
                    size: 14.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  currentMeal != null
                      ? 'Next meal: ${currentMeal.name}'
                      : 'Today\'s menu',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  '$mealsToday meals today',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Modern meal cards
          Container(
            height: 110.h, // More compact height
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis
                  .horizontal, // Change to horizontal for more natural swiping
              physics: BouncingScrollPhysics(),
              onPageChanged: (index) {
                _currentPage.value = index;
              },
              children: [
                if (previousMeal != null)
                  _buildModernMealCard(previousMeal, false)
                else
                  _buildEmptyMealCard("No previous meals"),
                if (currentMeal != null)
                  _buildModernMealCard(currentMeal, true)
                else
                  _buildEmptyMealCard("No upcoming meals"),
                if (nextMeal != null)
                  _buildModernMealCard(nextMeal, false)
                else
                  _buildEmptyMealCard("No more meals today"),
              ],
            ),
          ),

          // Modern dot indicators
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDotIndicator(0),
                  SizedBox(width: 6.w),
                  _buildDotIndicator(1),
                  SizedBox(width: 6.w),
                  _buildDotIndicator(2),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // Simplified dot indicator

  Widget _buildDotIndicator(int index) {
    return Obx(() {
      final isActive = _currentPage.value == index;
      return Container(
        width: 8.w,
        height: 8.w,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  // Clean, modern meal card
  Widget _buildModernMealCard(Meal meal, bool isUpcoming) {
    // Simple color scheme
    final cardColor = isUpcoming ? Colors.white : Colors.white;
    final accentColor = AppColors.primary;

    return Card(
      elevation: isUpcoming ? 1 : 0,
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color:
              isUpcoming ? accentColor.withOpacity(0.2) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple meal header
            Row(
              children: [
                // Meal name with icon
                Icon(
                  _getMealIcon(meal.id),
                  size: 16.sp,
                  color: isUpcoming ? accentColor : Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  meal.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                Spacer(),

                // Clean time display
                Text(
                  _formatCompactTimeRange(meal.startTime, meal.endTime),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isUpcoming ? accentColor : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Simple divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
            ),

            // Menu items in simple row
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(
                  children: meal.items.map((item) {
                    return Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? accentColor.withOpacity(0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isUpcoming
                              ? AppColors.textPrimary
                              : Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simplified empty states

  Widget _buildEmptyState() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SizedBox(
        height: 70.h,
        child: Center(
          child: Text(
            'No menu available today',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMealCard(String message) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // Format time range in a cleaner way
  String _formatCompactTimeRange(TimeOfDay start, TimeOfDay end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _getMealIcon(String mealId) {
    final id = mealId.toLowerCase();
    if (id.contains('breakfast')) return Icons.free_breakfast;
    if (id.contains('lunch')) return Icons.lunch_dining;
    if (id.contains('snack')) return Icons.cookie;
    if (id.contains('dinner')) return Icons.dinner_dining;
    return Icons.restaurant;
  }
}
