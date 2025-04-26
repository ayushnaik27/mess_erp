import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/core/services/user_service.dart';
import 'package:mess_erp/features/student/controllers/leave_controller.dart';
import 'package:mess_erp/features/student/models/meal_opt_out_model.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final LeaveController _controller = Get.put(LeaveController());
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final dateFormat = DateFormat('dd MMM, yyyy');

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Apply for Leave',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return _buildForm();
      }),
    );
  }

  Widget _buildForm() {
    final user = UserService.to.currentUser.value!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info card
            _buildInfoCard(user),

            SizedBox(height: 24.h),

            // Date selection
            Text(
              'Leave Duration',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            _buildDateSelection(),

            SizedBox(height: 24.h),
            // Reason input
            Text(
              'Reason for Leave',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason for leave',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason for leave';
                }
                return null;
              },
            ),

            SizedBox(height: 32.h),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Submit Leave Application',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Important notes
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20.sp,
                        color: Colors.amber.shade800,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Important Notes:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Leave applications are automatically approved\n'
                    '• You will not be charged for meals during your leave\n'
                    '• Leave can be applied for future dates only\n'
                    '• You can cancel your leave from the Track Leaves section',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(User user) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            user.id,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            'Hostel ${user.hostelId}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
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
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        dateFormat.format(_startDate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        dateFormat.format(_endDate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    DateTime initialDate = isStartDate ? _startDate : _endDate;
    DateTime firstDate = isStartDate ? DateTime.now() : _startDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before new start date, update end date too
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitLeave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = UserService.to.currentUser.value;
    if (user == null) {
      Get.snackbar(
        'Error',
        'User information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    final List<MealOptOut> mealsOptedOut = [];

    for (DateTime date = _startDate;
        !date.isAfter(_endDate);
        date = date.add(const Duration(days: 1))) {
      mealsOptedOut.add(MealOptOut(
        date: date,
        breakfast: true,
        lunch: true,
        snacks: true,
        dinner: true,
      ));
    }

    _controller.applyLeave(
      studentId: user.id,
      name: user.name,
      hostelId: user.hostelId,
      startDate: _startDate,
      endDate: _endDate,
      reason: _reasonController.text.trim(),
      mealsOptedOut: mealsOptedOut,
    );
  }
}
