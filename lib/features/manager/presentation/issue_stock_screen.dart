import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/manager/controllers/issue_stock_controller.dart';
import 'package:mess_erp/features/manager/models/stock_item_model.dart';

class IssueStockScreen extends GetView<IssueStockController> {
  const IssueStockScreen({Key? key}) : super(key: key);

  static const routeName = '/issueStock';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Stock'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchStockItems,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(
                  'Loading stock items...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalBalanceCard(),
              SizedBox(height: 24.h),
              _buildIssueStockForm(),
              SizedBox(height: 24.h),
              _buildItemDetailsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL INVENTORY VALUE',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() => Text(
                  '₹${NumberFormat('#,##,###.##').format(controller.totalBalance.value)}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )),
            SizedBox(height: 8.h),
            Text(
              'Total value of all items in stock',
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

  Widget _buildIssueStockForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ISSUE STOCK TO MESS',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 24.h),
            _buildItemDropdown(),
            SizedBox(height: 16.h),
            _buildQuantityInput(),
            SizedBox(height: 24.h),
            _buildSubmitButton(),
          ],
        ),
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          if (controller.stockItems.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'No stock items available',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButtonFormField<StockItem>(
              value: controller.selectedItem.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                border: InputBorder.none,
              ),
              items: controller.stockItems.map((item) {
                return DropdownMenuItem<StockItem>(
                  value: item,
                  child: Text(
                    '${item.name} (${item.quantity} units available)',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                );
              }).toList(),
              onChanged: controller.setSelectedItem,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity to Issue',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter quantity',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          onChanged: controller.setQuantityToIssue,
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final item = controller.selectedItem.value;
          if (item == null) return const SizedBox.shrink();

          final quantity = controller.quantityToIssue.value;
          if (quantity <= 0) return const SizedBox.shrink();

          final amount = item.ratePerUnit * quantity;

          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Value:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '₹${NumberFormat('#,##,###.##').format(amount)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : () async {
                final success = await controller.issueStock();
                if (success) {
                  Get.back();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: controller.isSubmitting.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Processing...',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline),
                  SizedBox(width: 8.w),
                  Text(
                    'Issue to Mess',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildItemDetailsCard() {
    return Obx(() {
      final item = controller.selectedItem.value;
      if (item == null) return const SizedBox.shrink();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ITEM DETAILS',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              _buildItemDetail('Item Name', item.name),
              _buildItemDetail('Available Quantity', '${item.quantity} units'),
              _buildItemDetail(
                  'Rate Per Unit', '₹${item.ratePerUnit.toStringAsFixed(2)}'),
              _buildItemDetail('Current Value',
                  '₹${NumberFormat('#,##,###.##').format(item.balance)}'),
              _buildItemDetail('Last Updated',
                  DateFormat('dd MMM yyyy, hh:mm a').format(item.updatedAt)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildItemDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
