import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';

class MetricsSection extends StatelessWidget {
  final MuneemDashboardController controller;

  const MetricsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
          Text(
            AppStrings.messOverview,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildMetricCard(
                      AppStrings.studentsPresent,
                      '${controller.presentStudentCount}',
                      Icons.people,
                      Colors.blue,
                    )),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(() => _buildMetricCard(
                      AppStrings.onLeave,
                      '${controller.leaveStudentCount}',
                      Icons.beach_access,
                      Colors.orange,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildMetricCard(
                      AppStrings.extraItems,
                      '₹${NumberFormat('#,##,###.##').format(controller.extraItemsTotal.value)}',
                      Icons.fastfood,
                      Colors.green,
                    )),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(() => _buildMetricCard(
                      AppStrings.todaysAttendance,
                      '${controller.todayAttendancePercentage.toStringAsFixed(1)}%',
                      Icons.analytics,
                      Colors.purple,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.weeklyAttendanceTrend,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 180.h,
            child: Obx(() => LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < controller.weekDays.length) {
                              return Text(
                                controller.weekDays[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.sp,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.weeklyAttendanceData,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
