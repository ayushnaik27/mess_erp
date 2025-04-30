import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/clerk/controllers/monthly_report_controller.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MonthlyReportController>();
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.monthlyFinancialReport,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => controller.loadAllData(),
            tooltip: AppStrings.refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildProgressLoader(controller);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(AppStrings.monthlySummary),
              SizedBox(height: 16.h),
              _buildFinancialSummaryCard(controller),
              SizedBox(height: 24.h),
              _buildSectionTitle(AppStrings.stockBalance),
              SizedBox(height: 16.h),
              _buildStockBalanceCard(controller),
              SizedBox(height: 24.h),
              _buildSectionTitle(AppStrings.dietCalculations),
              SizedBox(height: 16.h),
              _buildDietDetailsCard(controller),
              SizedBox(height: 24.h),
              _buildSectionTitle(AppStrings.billGeneration),
              SizedBox(height: 16.h),
              _buildBillGenerationCard(controller),
              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressLoader(MonthlyReportController controller) {
    // Track which operations have started/completed
    final bool expenditureStarted =
        controller.totalMonthlyExpenditure.value != -1;
    final bool previousStockStarted =
        controller.previousMonthStockBalance.value != -1;
    final bool nextStockStarted = controller.nextMonthStockBalance.value != -1;
    final bool assetsConsumedStarted =
        controller.assetsConsumedThisMonth.value != -1;
    final bool extraConsumedStarted = controller.totalExtraConsumed.value != -1;
    final bool dietsStarted = controller.totalDiets.value != -1;

    // Calculate approximate progress (6 main operations)
    final completedSteps = [
      expenditureStarted,
      previousStockStarted,
      nextStockStarted,
      assetsConsumedStarted,
      extraConsumedStarted,
      dietsStarted
    ].where((started) => started).length;

    final progressValue = completedSteps / 6;

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: progressValue > 0 ? progressValue : null,
                color: AppColors.primary,
                strokeWidth: 6,
              ),
              SizedBox(height: 24.h),
              Text(
                AppStrings.preparingMonthlyReport,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppStrings.thisWillTakeTime,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                width: 280.w,
                child: Column(
                  children: [
                    _buildLoadingStep(
                        AppStrings.fetchingExpenditures, expenditureStarted),
                    _buildLoadingStep(
                        AppStrings.fetchingPreviousStock, previousStockStarted),
                    _buildLoadingStep(
                        AppStrings.fetchingCurrentStock, nextStockStarted),
                    _buildLoadingStep(AppStrings.calculatingConsumption,
                        assetsConsumedStarted),
                    _buildLoadingStep(
                      AppStrings.calculatingExtraItems,
                      extraConsumedStarted,
                    ),
                    _buildLoadingStep(
                      AppStrings.calculatingTotalDiets,
                      dietsStarted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStep(String step, bool completed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? Colors.green.shade100 : Colors.grey.shade200,
              border: Border.all(
                color: completed ? Colors.green.shade700 : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: Center(
              child: completed
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.green.shade700,
                    )
                  : SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    completed ? Colors.green.shade700 : AppColors.textPrimary,
                fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(MonthlyReportController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialItem(
              AppStrings.totalMonthlyExpenditure,
              controller.totalMonthlyExpenditure.value,
              Icons.payments_outlined,
              Colors.blue,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.assetsConsumedThisMonth,
              controller.assetsConsumedThisMonth.value,
              Icons.account_balance_wallet_outlined,
              Colors.green,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.totalExtraConsumed,
              controller.totalExtraConsumed.value,
              Icons.restaurant_menu,
              Colors.orange,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBalanceCard(MonthlyReportController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialItem(
              AppStrings.previousMonthStockBalance,
              controller.previousMonthStockBalance.value,
              Icons.history,
              Colors.purple,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.nextMonthStockBalance,
              controller.nextMonthStockBalance.value,
              Icons.next_plan_outlined,
              Colors.indigo,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietDetailsCard(MonthlyReportController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 24.sp,
                  color: Colors.teal,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppStrings.totalDiets,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  controller.totalDiets.value != -1
                      ? controller.totalDiets.value.toString()
                      : '...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            _divider(),
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 24.sp,
                  color: Colors.blue,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppStrings.couponPrice,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 120.w,
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPrice,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixText: '₹ ',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        try {
                          controller.setCouponPrice(double.parse(value));
                        } catch (e) {
                          // Handle invalid input
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.balance,
              controller.balance.value,
              Icons.account_balance_outlined,
              Colors.green.shade700,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.perDietCostCalculated,
              controller.perDietCost.value,
              Icons.calculate_outlined,
              Colors.blue.shade700,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
            _divider(),
            Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 24.sp,
                  color: Colors.indigo,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppStrings.perDietCostRounded,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 120.w,
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: AppStrings.enterAmount,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixText: '₹ ',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        try {
                          controller.setRoundedPerDietCost(double.parse(value));
                        } catch (e) {
                          // Handle invalid input
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            _divider(),
            _buildFinancialItem(
              AppStrings.profit,
              controller.profit.value,
              Icons.trending_up,
              controller.profit.value >= 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              formatter: (value) => NumberFormat.currency(
                symbol: '₹',
                locale: 'hi_IN',
                decimalDigits: 2,
              ).format(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillGenerationCard(MonthlyReportController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.generateMonthlyBills,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppStrings.billGenerationWarning,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isGenerating.value ||
                            controller.roundedPerDietCost.value == -1
                        ? null
                        : () => controller.generateBill(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isGenerating.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                AppStrings.generatingBills,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            AppStrings.generateMonthlyBills,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    double value,
    IconData icon,
    Color color, {
    String Function(double)? formatter,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: color,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value != -1
              ? formatter != null
                  ? formatter(value)
                  : value.toString()
              : '...',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
