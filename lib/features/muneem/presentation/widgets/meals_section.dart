import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';

class MealsSection extends StatelessWidget {
  final MuneemDashboardController controller;

  const MealsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190.h,
      child: Obx(() {
        if (controller.todayMeals.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noMealsAvailable,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.todayMeals.length,
          itemBuilder: (context, index) {
            final meal = controller.todayMeals[index];
            final now = DateTime.now();

            // Determine if this meal is active based on current time
            bool isActive = false;
            if (meal.mealType.toLowerCase() == 'breakfast' &&
                now.hour >= 7 &&
                now.hour < 10) {
              isActive = true;
            } else if (meal.mealType.toLowerCase() == 'lunch' &&
                now.hour >= 12 &&
                now.hour < 15) {
              isActive = true;
            } else if (meal.mealType.toLowerCase() == 'dinner' &&
                now.hour >= 19 &&
                now.hour < 22) {
              isActive = true;
            }

            // Get time range based on meal type
            String timeRange;
            if (meal.mealType.toLowerCase() == 'breakfast') {
              timeRange = AppStrings.breakfastTime;
            } else if (meal.mealType.toLowerCase() == 'lunch') {
              timeRange = AppStrings.lunchTime;
            } else {
              timeRange = AppStrings.dinnerTime;
            }

            // Get status text
            String status;
            if (isActive) {
              status = AppStrings.activeNow;
            } else if ((meal.mealType.toLowerCase() == 'breakfast' &&
                    now.hour < 7) ||
                (meal.mealType.toLowerCase() == 'lunch' && now.hour < 12) ||
                (meal.mealType.toLowerCase() == 'dinner' && now.hour < 19)) {
              status = AppStrings.comingSoon;
            } else {
              status = AppStrings.completed;
            }

            return _buildMealCard(
              mealType: meal.mealType,
              time: timeRange,
              items: meal.items,
              status: status,
              isActive: isActive,
            );
          },
        );
      }),
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String time,
    required List<String> items,
    required String status,
    required bool isActive,
  }) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade800,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: isActive
                        ? null
                        : Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color:
                          isActive ? AppColors.primary : Colors.grey.shade600,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.menu,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 8.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  items[index],
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
