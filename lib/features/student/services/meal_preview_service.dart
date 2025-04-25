import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/services/user_service.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/features/committee/models/meal_model.dart';
import 'package:mess_erp/features/committee/repositories/mess_menu_repository.dart';

class MealPreviewService extends GetxService {
  final MessMenuRepository _repository = MessMenuRepository();
  final AppLogger _logger = AppLogger();

  // Single instance pattern
  static MealPreviewService get to => Get.find<MealPreviewService>();

  final Rx<DayMenu?> todayMenu = Rx<DayMenu?>(null);
  final Rx<Meal?> upcomingMeal = Rx<Meal?>(null);
  final RxInt upcomingMealIndex = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration(milliseconds: 500), () {
      _initializeMenu();
    });
  }

  Future<void> _initializeMenu() async {
    try {
      if (Get.isRegistered<UserService>()) {
        final hostelId = UserService.to.getCurrentHostelId();
        if (hostelId.isNotEmpty) {
          await loadTodayMenu(hostelId);
          return;
        }
      }

      final persistenceService = await AuthPersistenceService.getInstance();
      final user = await persistenceService.getCurrentUser();
      if (user != null && user.hostelId.isNotEmpty) {
        await loadTodayMenu(user.hostelId);
      } else {
        _logger.w('Could not determine hostel ID for meal preview');
      }
    } catch (e) {
      _logger.e('Error initializing meal preview: $e');
    }
  }

  Future<void> loadTodayMenu(String? hostelId) async {
    if (hostelId == null) return;

    try {
      isLoading.value = true;

      final weeklyMenu = await _repository.getWeeklyMenu(hostelId);
      if (weeklyMenu == null) {
        _logger.w('No weekly menu found for hostel: $hostelId');
        return;
      }

      // Get today's day name (Monday, Tuesday, etc.)
      final today = DateFormat('EEEE').format(DateTime.now());

      // Find today's menu in the weekly menu
      final todaysMenu = weeklyMenu.days.firstWhereOrNull(
          (day) => day.name.toLowerCase() == today.toLowerCase());

      if (todaysMenu == null) {
        _logger.w('No menu found for today: $today');
        return;
      }

      todayMenu.value = todaysMenu;
      _determineUpcomingMeal();
    } catch (e) {
      _logger.e('Error loading today\'s menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _determineUpcomingMeal() {
    if (todayMenu.value == null || todayMenu.value!.meals.isEmpty) return;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Default to first meal
    Meal nextMeal = todayMenu.value!.meals.first;
    int nextMealIndex = 0;

    // Find the next upcoming meal
    for (int i = 0; i < todayMenu.value!.meals.length; i++) {
      final meal = todayMenu.value!.meals[i];
      final startMinutes = meal.startTime.hour * 60 + meal.startTime.minute;

      // If this meal starts after current time, it's the next meal
      if (startMinutes > currentMinutes) {
        nextMeal = meal;
        nextMealIndex = i;
        break;
      }
    }

    // If all meals are in the past, keep the last meal as current
    upcomingMeal.value = nextMeal;
    upcomingMealIndex.value = nextMealIndex;
  }

  // Get previous meal if available
  Meal? getPreviousMeal() {
    if (todayMenu.value == null || upcomingMealIndex.value <= 0) return null;
    return todayMenu.value!.meals[upcomingMealIndex.value - 1];
  }

  // Get next meal if available
  Meal? getNextMeal() {
    if (todayMenu.value == null ||
        upcomingMealIndex.value >= todayMenu.value!.meals.length - 1)
      return null;
    return todayMenu.value!.meals[upcomingMealIndex.value + 1];
  }
}
