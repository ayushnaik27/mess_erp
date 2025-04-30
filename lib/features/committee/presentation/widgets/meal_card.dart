import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/committee/controllers/mess_menu_controller.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:mess_erp/features/committee/models/meal_model.dart';
import 'package:mess_erp/features/committee/presentation/widgets/menu_item_list.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final DayMenu day;
  final MessMenuController controller;

  const MealCard({
    Key? key,
    required this.meal,
    required this.day,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealColor = _getMealColor(meal.name);
    final now = TimeOfDay.now();
    final isActive = _isMealActive(meal, now);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              _buildMealHeader(context, mealColor, isActive),
              _buildMealContent(context, mealColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealHeader(
      BuildContext context, Color mealColor, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mealColor,
            mealColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.3),
            radius: 20.r,
            child: Icon(
              _getMealIcon(meal.name),
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 8.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Active Now',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: mealColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.8),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${_formatTimeOfDay(meal.startTime)} - ${_formatTimeOfDay(meal.endTime)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () => _showEditTimingDialog(
                        context,
                        controller,
                        day,
                        meal,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealContent(BuildContext context, Color mealColor) {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.menuItems,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddItemDialog(
                  context,
                  controller,
                  day,
                  meal,
                ),
                icon: Icon(
                  Icons.add,
                  size: 18.sp,
                  color: mealColor,
                ),
                label: Text(
                  AppStrings.addItem,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: mealColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: mealColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (meal.items.isEmpty)
            _buildEmptyItemsView(mealColor)
          else
            MenuItemList(
              day: day,
              meal: meal,
              controller: controller,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsView(Color mealColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48.sp,
            color: mealColor.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.noMenuItemsAdded,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTimingDialog(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
    Meal meal,
  ) {
    TimeOfDay startTime = meal.startTime;
    TimeOfDay endTime = meal.endTime;
    final mealColor = _getMealColor(meal.name);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: mealColor.withOpacity(0.1),
                        child: Icon(
                          Icons.access_time,
                          color: mealColor,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Timing - ${meal.name}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: mealColor,
                              ),
                            ),
                            Text(
                              'Set serving hours for ${meal.name.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildTimeSelector(
                    title: 'Start Time',
                    time: startTime,
                    color: mealColor,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: mealColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          startTime = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildTimeSelector(
                    title: 'End Time',
                    time: endTime,
                    color: mealColor,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: mealColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          endTime = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: () {
                          controller.updateMealTiming(
                            day.id,
                            meal.id,
                            startTime,
                            endTime,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mealColor,
                        ),
                        child: Text(
                          'Update',
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTimeOfDay(time),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: color,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
    Meal meal,
  ) {
    final TextEditingController textController = TextEditingController();
    final mealColor = _getMealColor(meal.name);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMealIcon(meal.name),
                  color: mealColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Add Menu Item - ${meal.name}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Food Item',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter food item (e.g., Pasta, Rice, etc.)',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: mealColor,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.restaurant,
                  color: mealColor,
                ),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      final updatedItems = List<String>.from(meal.items);
                      updatedItems.add(textController.text.trim());
                      controller.updateMealItems(day.id, meal.id, updatedItems);
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mealColor,
                  ),
                  child: Text(
                    'Add',
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
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  // Helper method to check if a meal is currently active
  bool _isMealActive(Meal meal, TimeOfDay now) {
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = meal.startTime.hour * 60 + meal.startTime.minute;
    final endMinutes = meal.endTime.hour * 60 + meal.endTime.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Color _getMealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9800); // Warm orange
      case 'lunch':
        return const Color(0xFF4CAF50); // Vibrant green
      case 'snacks':
        return const Color(0xFF9C27B0); // Purple
      case 'dinner':
        return const Color(0xFF2196F3); // Blue
      default:
        return AppColors.primary;
    }
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'snacks':
        return Icons.bakery_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}
