import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/manager/controllers/generate_voucher_controller.dart';
import 'package:mess_erp/features/manager/models/vender_model.dart';

class GenerateVoucherScreen extends GetView<GenerateVoucherController> {
  const GenerateVoucherScreen({Key? key}) : super(key: key);
  static const routeName = '/generateVoucher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Voucher'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                  'Loading data...',
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
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSelectionCard(),
          SizedBox(height: 24.h),
          Obx(() => _buildBillsTable()),
        ],
      ),
    );
  }

  Widget _buildSelectionCard() {
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
              'GENERATE PAYMENT VOUCHER',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 24.h),
            _buildMonthDropdown(),
            SizedBox(height: 16.h),
            _buildVendorDropdown(),
            SizedBox(height: 16.h),
            _buildDateRangeDropdown(),
            SizedBox(height: 24.h),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Month',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedMonth.isEmpty
                  ? null
                  : controller.selectedMonth.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                border: InputBorder.none,
                hintText: 'Select Month',
              ),
              items: [
                ...controller.months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month['value'],
                    child: Text(month['label']!),
                  );
                }).toList(),
              ],
              onChanged: controller.setSelectedMonth,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVendorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Vendor',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() {
            return DropdownButtonFormField<Vendor>(
              value:
                  null, // Can't set a value here because of the object reference
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                border: InputBorder.none,
                hintText: controller.selectedVendor.isEmpty
                    ? 'Select Vendor'
                    : controller.selectedVendor.value,
              ),
              items: controller.vendors.map((vendor) {
                return DropdownMenuItem<Vendor>(
                  value: vendor,
                  child: Text(vendor.name),
                );
              }).toList(),
              onChanged: controller.setSelectedVendor,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateRangeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date Range',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedDateRange.isEmpty
                  ? null
                  : controller.selectedDateRange.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                border: InputBorder.none,
                hintText: 'Select Date Range',
              ),
              items: controller.dateRanges.map((range) {
                return DropdownMenuItem<String>(
                  value: range['value'],
                  child: Text(range['label']!),
                );
              }).toList(),
              onChanged: controller.setSelectedDateRange,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() {
      final bool canGenerate = controller.bills.isNotEmpty &&
          controller.selectedMonth.isNotEmpty &&
          controller.selectedVendor.isNotEmpty &&
          controller.selectedDateRange.isNotEmpty;

      return ElevatedButton(
        onPressed: canGenerate && !controller.isSubmitting.value
            ? controller.generateVoucher
            : null,
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text('Processing...', style: TextStyle(fontSize: 16.sp)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Generate Voucher', style: TextStyle(fontSize: 16.sp)),
                ],
              ),
      );
    });
  }

  Widget _buildBillsTable() {
    if (controller.selectedMonth.isEmpty ||
        controller.selectedVendor.isEmpty ||
        controller.selectedDateRange.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'Select month, vendor, and date range to view bills',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.bills.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No bills found for the selected criteria',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              OutlinedButton.icon(
                onPressed: controller.fetchBillsForVoucher,
                icon: Icon(Icons.refresh_outlined),
                label: Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bills Available for Voucher',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${controller.bills.length} ${controller.bills.length == 1 ? 'Bill' : 'Bills'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20.w,
                    dataRowHeight: 56.h,
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey.shade100),
                    columns: [
                      DataColumn(
                        label: Text(
                          'S.No',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Bill Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Bill Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount (₹)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: controller.bills.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bill = entry.value;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text((index + 1).toString()),
                          ),
                          DataCell(
                            Text(bill.billNumber),
                          ),
                          DataCell(
                            Text(
                                DateFormat('dd-MM-yyyy').format(bill.billDate)),
                          ),
                          DataCell(
                            Text(
                              NumberFormat('#,##,###.##')
                                  .format(bill.billAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Card(
            color: Colors.grey.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Obx(() {
                    final totalAmount = controller.bills
                        .fold(0.0, (sum, bill) => sum + bill.billAmount);

                    return Text(
                      '₹ ${NumberFormat('#,##,###.##').format(totalAmount)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
