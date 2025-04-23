import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/student/controllers/student_dashboard_controller.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const routeName = '/applyLeave';

  const ApplyLeaveScreen({super.key});

  @override
  _ApplyLeaveScreenState createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  // Use existing controller
  final StudentDashboardController _controller =
      Get.find<StudentDashboardController>();

  DateTime selectedFromDate = DateTime.now().add(const Duration(days: 1));
  String selectedFromMeal = '';
  DateTime selectedToDate = DateTime.now().add(const Duration(days: 2));
  String selectedToMeal = '';
  List<String> fromMealOptions = ['Breakfast', 'Lunch', 'Dinner'];
  List<String> toMealOptions = ['Breakfast', 'Lunch', 'Dinner'];

  // Keep all existing functions as they are
  void showFromMealOptions() {
    List<String> options = [];
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    int currentSystemTime = DateTime.now().hour;

    if (selectedFromDate.day == tomorrow.day) {
      if (currentSystemTime < 11) {
        setState(() {
          options = ['Breakfast', 'Lunch', 'Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
        });
      } else if (currentSystemTime < 15) {
        setState(() {
          options = ['Lunch', 'Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
        });
      } else if (currentSystemTime < 22) {
        setState(() {
          options = ['Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
        });
      } else {
        _showErrorDialog(
            'Cannot apply for leave', 'You cannot apply for leave after 10pm');
        return;
      }
    } else {
      setState(() {
        options = ['Breakfast', 'Lunch', 'Dinner'];
        selectedFromMeal = options[0];
        selectedToMeal = '';
        selectedToDate = selectedFromDate;
      });
    }

    _showMealSelectionDialog('Select Start Meal', options, (meal) {
      setState(() {
        selectedFromMeal = meal;
      });
    });
  }

  void showToMealOptions() {
    List<String> allMeals = ['Breakfast', 'Lunch', 'Dinner'];
    List<String> options = [];

    // Handle case when selectedToDate is the same as selectedFromDate
    if (selectedFromDate.day == selectedToDate.day &&
        selectedFromDate.month == selectedToDate.month &&
        selectedFromDate.year == selectedToDate.year) {
      options = ['Dinner'];
    }
    // Handle case when selectedToDate is the day immediately following selectedFromDate
    else if (selectedToDate.isAfter(selectedFromDate) &&
        selectedToDate
            .isBefore(selectedFromDate.add(const Duration(days: 2)))) {
      if (selectedFromMeal == 'Breakfast') {
        options = allMeals;
      } else if (selectedFromMeal == 'Lunch') {
        options = ['Breakfast', 'Lunch', 'Dinner'];
      } else {
        options = ['Dinner'];
      }
    }
    // Handle case when selectedToDate spans multiple days
    else {
      options = allMeals;
    }

    // Set the default selectedToMeal to the first option
    setState(() {
      selectedToMeal = options.isNotEmpty ? options[0] : '';
    });

    if (options.isEmpty) {
      _showErrorDialog('Invalid Selection',
          'No meal options available for the selected dates');
      return;
    }

    _showMealSelectionDialog('Select End Meal', options, (meal) {
      setState(() {
        selectedToMeal = meal;
      });
    });
  }

  void _showMealSelectionDialog(
      String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              ...options.map((meal) => _buildMealOption(meal, onSelect)),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealOption(String meal, Function(String) onSelect) {
    IconData mealIcon;
    Color mealColor;

    switch (meal) {
      case 'Breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        mealColor = Colors.orange.shade700;
        break;
      case 'Lunch':
        mealIcon = Icons.lunch_dining_outlined;
        mealColor = Colors.green.shade700;
        break;
      case 'Dinner':
        mealIcon = Icons.nightlight_outlined;
        mealColor = Colors.indigo;
        break;
      default:
        mealIcon = Icons.restaurant_outlined;
        mealColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        onSelect(meal);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: mealColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(mealIcon, color: mealColor, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Text(
              meal,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        title: Text(
          'Apply for Leave',
          style: TextStyle(
            fontSize: 18.sp, // Reduced size to avoid overflow
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 12.h), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionCard(),
              SizedBox(height: 20.h), // Reduced spacing
              _buildDateSelectionCard(),
              SizedBox(height: 20.h), // Reduced spacing
              _buildMealSelectionCard(),
              SizedBox(height: 24.h), // Reduced spacing
              _buildSubmitButton(),
              SizedBox(height: 16.h), // Added bottom padding for scrolling
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: EdgeInsets.all(12.w), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligned to top
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade800,
            size: 22.sp, // Reduced size
          ),
          SizedBox(width: 12.w), // Reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Application Guidelines',
                  style: TextStyle(
                    fontSize: 15.sp, // Reduced size
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 4.h), // Reduced spacing
                Text(
                  '• Apply at least 24 hours in advance\n• Cannot apply after 10pm for next day\n• Select both start and end meals',
                  style: TextStyle(
                    fontSize: 12.sp, // Reduced size
                    color: Colors.blue.shade700,
                    height: 1.4, // Reduced line height
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return Container(
      padding: EdgeInsets.all(16.w), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r), // Reduced radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                color: AppColors.primary,
                size: 20.sp, // Reduced size
              ),
              SizedBox(width: 8.w), // Reduced spacing
              Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: 16.sp, // Reduced size
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h), // Reduced spacing
          // Use a responsive layout approach for smaller screens
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 340) {
                // For very small screens, stack vertically
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateField(
                      label: 'Start Date',
                      date: selectedFromDate,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedFromDate,
                          firstDate:
                              DateTime.now().add(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: AppColors.primary),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedFromDate = picked;
                            selectedFromMeal = '';
                            selectedToMeal = '';
                            selectedToDate = picked;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildDateField(
                      label: 'End Date',
                      date: selectedToDate,
                      onTap: () async {
                        if (selectedFromMeal.isEmpty) {
                          _showErrorDialog('Select Start Meal First',
                              'Please select a start meal before choosing an end date');
                          return;
                        }

                        DateTime firstDate = selectedFromMeal == 'Breakfast'
                            ? selectedFromDate
                            : selectedFromDate.add(const Duration(days: 1));

                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: firstDate,
                          firstDate: firstDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: AppColors.primary),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedToDate = picked;
                            selectedToMeal = '';
                          });
                        }
                      },
                    ),
                  ],
                );
              } else {
                // For larger screens, keep the row layout
                return Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Start Date',
                        date: selectedFromDate,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedFromDate,
                            firstDate:
                                DateTime.now().add(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                      primary: AppColors.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedFromDate = picked;
                              selectedFromMeal = '';
                              selectedToMeal = '';
                              selectedToDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12.w), // Reduced spacing
                    Expanded(
                      child: _buildDateField(
                        label: 'End Date',
                        date: selectedToDate,
                        onTap: () async {
                          if (selectedFromMeal.isEmpty) {
                            _showErrorDialog('Select Start Meal First',
                                'Please select a start meal before choosing an end date');
                            return;
                          }

                          DateTime firstDate = selectedFromMeal == 'Breakfast'
                              ? selectedFromDate
                              : selectedFromDate.add(const Duration(days: 1));

                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: firstDate,
                            firstDate: firstDate,
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                      primary: AppColors.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedToDate = picked;
                              selectedToMeal = '';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FittedBox to prevent overflow with date text
                Expanded(
                  child: Text(
                    // Use more compact date format on smaller screens
                    MediaQuery.of(context).size.width < 360
                        ? DateFormat('dd/MM/yy').format(date)
                        : DateFormat('dd MMM yyyy').format(date),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8.w), // Add space between text and icon
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSelectionCard() {
    return Container(
      padding: EdgeInsets.all(16.w), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r), // Reduced radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_outlined,
                color: AppColors.primary,
                size: 20.sp, // Reduced size
              ),
              SizedBox(width: 8.w), // Reduced spacing
              Text(
                'Select Meals',
                style: TextStyle(
                  fontSize: 16.sp, // Reduced size
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h), // Reduced spacing
          // Use a responsive layout approach for smaller screens
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 340) {
                // For very small screens, stack vertically
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealField(
                      label: 'Start Meal',
                      meal: selectedFromMeal,
                      isSelected: selectedFromMeal.isNotEmpty,
                      onTap: showFromMealOptions,
                    ),
                    SizedBox(height: 12.h),
                    _buildMealField(
                      label: 'End Meal',
                      meal: selectedToMeal,
                      isSelected: selectedToMeal.isNotEmpty,
                      onTap: selectedFromMeal.isEmpty
                          ? () => _showErrorDialog('Select Start Meal First',
                              'Please select a start meal before choosing an end meal')
                          : showToMealOptions,
                    ),
                  ],
                );
              } else {
                // For larger screens, keep the row layout
                return Row(
                  children: [
                    Expanded(
                      child: _buildMealField(
                        label: 'Start Meal',
                        meal: selectedFromMeal,
                        isSelected: selectedFromMeal.isNotEmpty,
                        onTap: showFromMealOptions,
                      ),
                    ),
                    SizedBox(width: 12.w), // Reduced spacing
                    Expanded(
                      child: _buildMealField(
                        label: 'End Meal',
                        meal: selectedToMeal,
                        isSelected: selectedToMeal.isNotEmpty,
                        onTap: selectedFromMeal.isEmpty
                            ? () => _showErrorDialog('Select Start Meal First',
                                'Please select a start meal before choosing an end meal')
                            : showToMealOptions,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealField({
    required String label,
    required String meal,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData mealIcon;
    Color mealColor;

    switch (meal) {
      case 'Breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        mealColor = Colors.orange.shade700;
        break;
      case 'Lunch':
        mealIcon = Icons.lunch_dining_outlined;
        mealColor = Colors.green.shade700;
        break;
      case 'Dinner':
        mealIcon = Icons.nightlight_outlined;
        mealColor = Colors.indigo;
        break;
      default:
        mealIcon = Icons.restaurant_menu_outlined;
        mealColor = Colors.grey.shade600;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp, // Reduced size
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h), // Reduced spacing
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12.w, vertical: 10.h), // Reduced padding
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? mealColor.withOpacity(0.5)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8.r),
              color: isSelected ? mealColor.withOpacity(0.05) : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.isNotEmpty ? meal : 'Select meal',
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  style: TextStyle(
                    fontSize: 14.sp, // Reduced size
                    fontWeight: FontWeight.w500,
                    color: isSelected ? mealColor : Colors.grey.shade500,
                  ),
                ),
                Icon(
                  isSelected ? mealIcon : Icons.arrow_drop_down,
                  size: 18.sp, // Reduced size
                  color: isSelected ? mealColor : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    bool canSubmit = selectedFromMeal.isNotEmpty && selectedToMeal.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 48.h, // Reduced height
      child: ElevatedButton(
        onPressed: canSubmit
            ? () {
                // Using userRollNumber from controller instead of Provider
                _submitLeaveRequest(_controller.userRollNumber ?? '')
                    .then((value) {
                  if (!value) {
                    _showErrorDialog('Invalid Selection',
                        'You cannot apply for leave before your last leave date. Please select another date.');
                  } else {
                    Get.snackbar(
                      'Success',
                      'Leave request submitted successfully!',
                      backgroundColor: Colors.green.shade700,
                      colorText: Colors.white,
                      margin: EdgeInsets.all(8),
                      borderRadius: 10,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    Get.back();
                  }
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r), // Reduced radius
          ),
          elevation: 0,
        ),
        child: Text(
          'Submit Leave Request',
          style: TextStyle(
            fontSize: 15.sp, // Reduced size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<bool> _submitLeaveRequest(String rollNumber) async {
    try {
      QuerySnapshot leaveDetailSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('leaveDetails')
          .get();

      if (leaveDetailSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot lastLeaveDetailSnapshot =
            leaveDetailSnapshot.docs.last;

        DateTime lastLeaveDate = DateTime(
          lastLeaveDetailSnapshot['year'],
          lastLeaveDetailSnapshot['month'],
          lastLeaveDetailSnapshot['day'],
        );

        if (selectedFromDate.isBefore(lastLeaveDate)) {
          return false;
        }
      }

      List<DateTime> datesToApply = [];

      for (DateTime date = selectedFromDate;
          date.isBefore(selectedToDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        datesToApply.add(date);
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DateTime date in datesToApply) {
        List<String> onLeaveMeals = [];
        if (date.day == selectedFromDate.day &&
            date.month == selectedFromDate.month &&
            date.year == selectedFromDate.year) {
          // First day - include selected meal and after
          int startIndex = fromMealOptions.indexOf(selectedFromMeal);
          onLeaveMeals.addAll(fromMealOptions.sublist(startIndex));
        } else if (date.day == selectedToDate.day &&
            date.month == selectedToDate.month &&
            date.year == selectedToDate.year) {
          // Last day - include meals up to selected meal
          int endIndex = toMealOptions.indexOf(selectedToMeal);
          onLeaveMeals.addAll(toMealOptions.sublist(0, endIndex + 1));
        } else {
          // Middle days - include all meals
          onLeaveMeals.addAll(toMealOptions);
        }

        String leaveDate = DateFormat('dd-MM-yyyy').format(date);

        DocumentReference newLeaveDocRef = FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('newLeaveDetails')
            .doc(leaveDate);

        batch.set(
          newLeaveDocRef,
          {
            'date': leaveDate,
            'onLeaveMeals': onLeaveMeals,
            'timestamp': date,
            'fromDate': DateFormat('dd-MM-yyyy').format(selectedFromDate),
            'toDate': DateFormat('dd-MM-yyyy').format(selectedToDate),
          },
          SetOptions(merge: true),
        );

        DocumentReference leaveDetailDocRef = FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('leaveDetails')
            .doc();

        batch.set(
          leaveDetailDocRef,
          {
            'day': date.day,
            'month': date.month,
            'year': date.year,
            'onLeave': true,
            'leaveCount': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return true;
    } catch (e, stackTrace) {
      log('Error submitting leave request: $e', stackTrace: stackTrace);
      return false;
    }
  }
}
