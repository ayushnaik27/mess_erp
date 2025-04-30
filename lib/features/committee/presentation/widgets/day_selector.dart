import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/committee/controllers/mess_menu_controller.dart';

class DaySelector extends StatelessWidget {
  final MessMenuController controller;

  const DaySelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.h),
      child: Obx(() {
        if (controller.weeklyMenu.value == null) return const SizedBox.shrink();

        return Container(
          color: AppColors.primary,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.weeklyMenu.value!.days.map((day) {
                final isSelected = controller.selectedDayId.value == day.id;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkWell(
                    onTap: () => controller.selectDay(day.id),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            day.isWeekend
                                ? Icons.weekend
                                : Icons.calendar_today,
                            size: 18.sp,
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            day.name,
                            style: TextStyle(
                              color:
                                  isSelected ? AppColors.primary : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
