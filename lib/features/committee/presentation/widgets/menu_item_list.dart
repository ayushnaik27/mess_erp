import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/committee/controllers/mess_menu_controller.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:mess_erp/features/committee/models/meal_model.dart';

class MenuItemList extends StatelessWidget {
  final DayMenu day;
  final Meal meal;
  final MessMenuController controller;

  const MenuItemList({
    Key? key,
    required this.day,
    required this.meal,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...meal.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              title: Text(
                item,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              leading: Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getMealColor(meal.name).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _getMealColor(meal.name),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => _showEditItemDialog(
                      context,
                      controller,
                      day,
                      meal,
                      index,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20.sp,
                      color: AppColors.error,
                    ),
                    onPressed: () => _showDeleteItemDialog(
                      context,
                      controller,
                      day,
                      meal,
                      index,
                    ),
                  ),
                ],
              ),
              onTap: () => _showEditItemDialog(
                context,
                controller,
                day,
                meal,
                index,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
    Meal meal,
    int index,
  ) {
    final TextEditingController textController =
        TextEditingController(text: meal.items[index]);
    final mealColor = _getMealColor(meal.name);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: mealColor.withOpacity(0.1),
                    child: Icon(
                      Icons.edit,
                      color: mealColor,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'Edit Menu Item',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter food item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: mealColor, width: 2),
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
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        final updatedItems = List<String>.from(meal.items);
                        updatedItems[index] = textController.text.trim();
                        controller.updateMealItems(
                            day.id, meal.id, updatedItems);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mealColor,
                    ),
                    child: Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteItemDialog(
    BuildContext context,
    MessMenuController controller,
    DayMenu day,
    Meal meal,
    int index,
  ) {
    final itemName = meal.items[index];

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
                Icons.delete_outline,
                color: Colors.red,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Delete Item',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Are you sure you want to delete this item?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                itemName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final updatedItems = List<String>.from(meal.items);
                      updatedItems.removeAt(index);
                      controller.updateMealItems(day.id, meal.id, updatedItems);
                      Get.back();
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
}
