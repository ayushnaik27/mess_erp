import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:mess_erp/features/committee/models/meal_model.dart';
import 'package:mess_erp/features/committee/repositories/mess_menu_repository.dart';

class MessMenuScreen extends StatefulWidget {
  static const String routeName = '/mess-menu';
  final String hostelId;

  const MessMenuScreen({super.key, required this.hostelId});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen>
    with SingleTickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  final MessMenuRepository _repository = MessMenuRepository();

  late TabController _tabController;
  final RxBool _isLoading = true.obs;
  final Rx<List<DayMenu>> _weeklyMenu = Rx<List<DayMenu>>([]);

  // Track if it's weekend menu
  final RxBool _isWeekend = false.obs;

  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  final RxInt _selectedDayIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Get today's index BEFORE loading menu
    final today = DateFormat('EEEE').format(DateTime.now());
    final todayIndex =
        _weekdays.indexWhere((day) => day.toLowerCase() == today.toLowerCase());

    // Always initialize selected day to today, or first day if today not found
    if (todayIndex != -1) {
      _selectedDayIndex.value = todayIndex;
    }

    _loadWeeklyMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklyMenu() async {
    try {
      _isLoading.value = true;
      final weeklyMenu = await _repository.getWeeklyMenu(widget.hostelId);
      if (weeklyMenu != null) {
        _weeklyMenu.value = weeklyMenu.days;

        // Determine if it's a weekend menu using multiple approaches
        final now = DateTime.now();
        final isWeekendDay = (now.weekday == DateTime.saturday ||
            now.weekday == DateTime.sunday);

        // Check if any day menu or meal has "weekend" in its name/id
        final hasWeekendMenu = weeklyMenu.days.any((day) =>
            day.name.toLowerCase().contains('weekend') ||
            day.meals.any((meal) => meal.id.toLowerCase().contains('weekend')));

        // Set weekend flag if either condition is true
        _isWeekend.value = isWeekendDay || hasWeekendMenu;

        // Set tab controller to day view (index 0)
        _tabController.animateTo(0);

        // Don't reset _selectedDayIndex here - that's causing the Monday issue
      } else {
        _weeklyMenu.value = [];
      }
    } catch (e) {
      _logger.e('Error loading weekly menu', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Mess Menu - Hostel ${widget.hostelId}',
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadWeeklyMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Day View', icon: Icon(Icons.view_day, size: 18.sp)),
            Tab(text: 'Table View', icon: Icon(Icons.grid_on, size: 18.sp)),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (_weeklyMenu.value.isEmpty) {
          return _buildEmptyState();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildDayView(),
            // _buildTableView(),
            _buildImprovedTableView(),
          ],
        );
      }),
    );
  }

  Widget _buildImprovedTableView() {
    // Calculate today's index
    final today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    final todayIndex =
        _weekdays.indexWhere((day) => day.toLowerCase() == today);

    // Calculate current active meal
    String currentMealType = '';
    for (String mealType in _mealTypes) {
      if (_isCurrentMeal(mealType)) {
        currentMealType = mealType;
        break;
      }
    }

    return Column(
      children: [
        // Status bar with date and current meal
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (currentMealType.isNotEmpty)
                    Text(
                      'Current Meal: $currentMealType',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13.sp,
                      ),
                    ),
                ],
              ),
              Spacer(),
              // Weekend badge if applicable
              if (_isWeekend.value)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.weekend,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Weekend Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Day selection tabs
        Container(
          height: 60.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: _weekdays.length,
            itemBuilder: (context, index) {
              final isToday = index == todayIndex;
              final day = _weekdays[index];

              // Check if this day has any special menu items
              final dayMenu = _findDayMenu(day);
              final hasSpecialItems = dayMenu?.meals.any((meal) => meal.items
                      .any((item) => item.toLowerCase().contains('special'))) ??
                  false;

              return GestureDetector(
                onTap: () {
                  // Scroll to this day in the main content
                  // This would require implementing a scroll controller
                  _showDayMenuDetails(day);
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 40.w) /
                      4, // Show about 4 days at once
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.substring(0, 3),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isToday ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (hasSpecialItems)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.white.withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Special',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: isToday ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Meal type selector
        Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: _mealTypes.map((mealType) {
              final isActive = _isCurrentMeal(mealType);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Scroll to this meal section
                    // This would require implementing a scroll controller
                    _showMealTypeMenu(mealType);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getMealIcon(mealType),
                          size: 16.sp,
                          color: isActive ? Colors.white : Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          mealType
                              .split(' ')
                              .first, // Just show first word if space-separated
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isActive ? Colors.white : Colors.grey.shade700,
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

        SizedBox(height: 16.h),

        // Main content - meal cards by day
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _weekdays.length,
            itemBuilder: (context, dayIndex) {
              final day = _weekdays[dayIndex];
              final isToday = dayIndex == todayIndex;
              final dayMenu = _findDayMenu(day);

              return Container(
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: isToday
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: isToday
                      ? Border.all(color: AppColors.primary.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Spacer(),
                          if (isToday)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.today,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Meals for this day
                    if (dayMenu != null)
                      ...dayMenu.meals.map((meal) {
                        final isActiveMeal =
                            isToday && _isCurrentMeal(meal.name);

                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade100),
                            ),
                            color: isActiveMeal
                                ? AppColors.primary.withOpacity(0.03)
                                : Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meal header with time
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: isActiveMeal
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      _getMealIcon(meal.name),
                                      size: 18.sp,
                                      color: isActiveMeal
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isActiveMeal
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatTimeRange(
                                            meal.startTime, meal.endTime),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  if (isActiveMeal)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        'Now',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              // Meal items preview
                              ...meal.items.take(2).map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 5.h),
                                        width: 5.w,
                                        height: 5.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActiveMeal
                                              ? AppColors.primary
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              if (meal.items.length > 2)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: GestureDetector(
                                    onTap: () => _showFullMealDetails(meal),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.h,
                                        horizontal: 12.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActiveMeal
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'View all ${meal.items.length} items',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w500,
                                              color: isActiveMeal
                                                  ? AppColors.primary
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 14.sp,
                                            color: isActiveMeal
                                                ? AppColors.primary
                                                : Colors.grey.shade700,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      Container(
                        padding: EdgeInsets.all(20.w),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.no_meals,
                              size: 48.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No menu available for $day',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

// Add these new methods to handle the new UI interactions
  void _showDayMenuDetails(String day) {
    final dayMenu = _findDayMenu(day);
    if (dayMenu == null) return;

    // Find the index of the day to set the selected day
    final dayIndex = _weekdays.indexWhere((d) => d == day);
    if (dayIndex != -1) {
      // Switch to day view tab and select the day
      _tabController.animateTo(0);
      _selectedDayIndex.value = dayIndex;
    }
  }

  void _showMealTypeMenu(String mealType) {
    // Show a filtered view of just this meal type across all days
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMealIcon(mealType),
                    size: 22.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '$mealType Menu - All Week',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Content - Show this meal type across all days
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _weekdays.length,
                itemBuilder: (context, index) {
                  final day = _weekdays[index];
                  final dayMenu = _findDayMenu(day);
                  final meal = dayMenu != null
                      ? _findMealByType(dayMenu, mealType)
                      : null;

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day header
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Meal items
                        if (meal != null)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: meal.items.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.all(16.w),
                            alignment: Alignment.center,
                            child: Text(
                              'No $mealType available for $day',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showFullMealDetails(Meal meal) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getMealIcon(meal.name),
                    color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  meal.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  _formatTimeRange(meal.startTime, meal.endTime),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            Divider(height: 24.h, thickness: 1, color: Colors.grey.shade200),

            Text(
              'Menu Items',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: 12.h),

            // Show all items
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: meal.items.map((item) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No menu available',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: _loadWeeklyMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute =
        time.minute == 0 ? '' : ':${time.minute.toString().padLeft(2, '0')}';
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour$minute $period';
  }

  Widget _buildDayView() {
    final today = DateFormat('EEEE').format(DateTime.now());
    final todayIndex =
        _weekdays.indexWhere((day) => day.toLowerCase() == today.toLowerCase());
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: _weekdays.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = _selectedDayIndex.value == index;
                  final isToday = index == todayIndex;

                  return GestureDetector(
                    // Just update the value, no setState needed here
                    onTap: () => _selectedDayIndex.value = index,
                    child: Container(
                      margin: EdgeInsets.only(right: 12.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdays[index].substring(0, 3),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              width: 4.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          SizedBox(height: 24.h),

          // Selected day meals - now using Obx for reactivity
          Expanded(
            child: Obx(() {
              final selectedDay = _weekdays[_selectedDayIndex.value];
              final dayMenu = _findDayMenu(selectedDay);
              final isToday = _selectedDayIndex.value == todayIndex;

              return dayMenu != null
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _mealTypes.length,
                      itemBuilder: (context, index) {
                        final mealType = _mealTypes[index];
                        final meal = _findMealByType(dayMenu, mealType);
                        final isActiveMeal =
                            isToday && _isCurrentMeal(mealType);

                        return _buildDetailedMealCard(
                            mealType, meal, isActiveMeal);
                      },
                    )
                  : Center(
                      child: Text(
                        'No menu available for ${selectedDay}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMealCard(String mealType, Meal? meal, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  isActive ? AppColors.primary.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getMealIcon(mealType),
                  color: isActive ? AppColors.primary : Colors.grey.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  mealType,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    _getMealTime(mealType),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal items
          if (meal != null && meal.items.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppColors.primary
                                : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(16.w),
              alignment: Alignment.center,
              child: Text(
                'No items available',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(
        begin: 0.05, end: 0, curve: Curves.easeOutQuad, duration: 600.ms);
  }

  // Helper methods
  DayMenu? _findDayMenu(String day) {
    return _weeklyMenu.value.firstWhereOrNull(
        (menu) => menu.name.toLowerCase() == day.toLowerCase());
  }

  Meal? _findMealByType(DayMenu dayMenu, String type) {
    return dayMenu.meals.firstWhereOrNull(
        (meal) => meal.name.toLowerCase().contains(type.toLowerCase()));
  }

  bool _isCurrentMeal(String mealType) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        // 7:00 AM to 9:00 AM
        return currentMinutes >= 7 * 60 && currentMinutes <= 9 * 60;
      case 'lunch':
        // 12:00 PM to 2:00 PM
        return currentMinutes >= 12 * 60 && currentMinutes <= 14 * 60;
      case 'snacks':
        // 4:30 PM to 6:00 PM
        return currentMinutes >= 16 * 60 + 30 && currentMinutes <= 18 * 60;
      case 'dinner':
        // 7:30 PM to 9:30 PM
        return currentMinutes >= 19 * 60 + 30 && currentMinutes <= 21 * 60 + 30;
      default:
        return false;
    }
  }

  String _getMealTime(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '7:00 AM - 9:00 AM';
      case 'lunch':
        return '12:00 PM - 2:00 PM';
      case 'snacks':
        return '4:30 PM - 6:00 PM';
      case 'dinner':
        return '7:30 PM - 9:30 PM';
      default:
        return '';
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'snacks':
        return Icons.cookie;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}
