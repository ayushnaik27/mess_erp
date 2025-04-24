import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';

class MuneemBottomNavigation extends StatelessWidget {
  const MuneemBottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
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
                icon: Icons.dashboard_rounded,
                label: AppStrings.dashboard,
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: AppStrings.meals,
                isSelected: false,
                onTap: () => Get.toNamed('/nextThreeMeals'),
              ),
              _buildNavItem(
                icon: Icons.fastfood_rounded,
                label: AppStrings.extraItems,
                isSelected: false,
                onTap: () => Get.toNamed('/approveExtraItems'),
              ),
              _buildNavItem(
                icon: Icons.people_alt_rounded,
                label: AppStrings.students,
                isSelected: false,
                onTap: () => Get.toNamed('/studentsOnLeave'),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
