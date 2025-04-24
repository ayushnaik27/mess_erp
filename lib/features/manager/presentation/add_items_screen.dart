import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/manager/controllers/add_item_controller.dart';

class AddItemScreen extends GetView<AddItemController> {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildForm(context);
      }),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildItemDropdown(),
          SizedBox(height: 16.h),
          _buildCategoryDropdown(),
          SizedBox(height: 16.h),
          _buildOtherItemField(),
          SizedBox(height: 16.h),
          _buildRateField(),
          SizedBox(height: 16.h),
          _buildQuantityField(),
          SizedBox(height: 24.h),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildItemDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Item',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() {
            final items = controller.items.map((item) => item.name).toList();

            return DropdownButtonFormField<String>(
              value: controller.selectedItem.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                border: InputBorder.none,
              ),
              items: [
                ...items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Other (Add New)'),
                ),
              ],
              onChanged: controller.setSelectedItem,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(); // Hide if no categories available
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButtonFormField<String>(
              value: controller.selectedCategory.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                border: InputBorder.none,
              ),
              items: controller.categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: controller.setSelectedCategory,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOtherItemField() {
    return Obx(() {
      if (!controller.isOtherItem.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Item Name',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.otherItemController,
            decoration: InputDecoration(
              hintText: 'Enter item name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 16.h,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Per Unit (₹)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.rateController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter rate per unit',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
          onChanged: (value) {
            controller.ratePerUnit.value = double.tryParse(value) ?? 0.0;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity Received',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter quantity received',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
          onChanged: (value) {
            controller.quantityReceived.value = int.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : () => controller.submitItem(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                controller.isOtherItem.value ? 'Add New Item' : 'Update Item',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    });
  }
}
