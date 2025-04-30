import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/services/user_service.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/committee/models/meal_model.dart';
import 'package:mess_erp/features/committee/models/day_menu_model.dart';
import 'package:mess_erp/features/committee/models/weekly_menu_model.dart';
import 'package:mess_erp/features/committee/repositories/committee_repository.dart';
import 'package:mess_erp/features/committee/repositories/mess_menu_repository.dart';

class MessMenuController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<WeeklyMenu?> weeklyMenu = Rx<WeeklyMenu?>(null);
  final MessMenuRepository _repository = MessMenuRepository();

  final RxString selectedDayId = ''.obs;
  final RxString selectedMealId = ''.obs;

  final RxString hostelId = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await _initializeHostelId();
    fetchWeeklyMenu();
  }

  Future<void> _initializeHostelId() async {
    try {
      isLoading.value = true;

      if (Get.isRegistered<UserService>()) {
        final userService = UserService.to;

        if (userService.hasValidHostelId()) {
          hostelId.value = userService.getCurrentHostelId();
          return;
        }
      }

      // Try to get from arguments if passed
      if (Get.arguments != null && Get.arguments['hostelId'] != null) {
        hostelId.value = Get.arguments['hostelId'];
        return;
      }

      final authPersistence = await AuthPersistenceService.getInstance();
      final user = await authPersistence.getCurrentUser();
      if (user != null && user.hostelId.isNotEmpty) {
        hostelId.value = user.hostelId;
        return;
      }

      final userId = authPersistence.getUserId();
      if (userId != null) {
        final committeeRepo = CommitteeRepository();
        final committeeUser = await committeeRepo.getCommitteeUserById(userId);
        if (committeeUser != null && committeeUser.hostelId.isNotEmpty) {
          hostelId.value = committeeUser.hostelId;
          return;
        }
      }

      // Last resort - use default
      hostelId.value = 'default_hostel';
      hasError.value = true;
      errorMessage.value = 'Could not determine hostel ID. Using default.';
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error initializing hostel ID: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeeklyMenu() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final menu = await _repository.getWeeklyMenu(hostelId.value);

      if (menu != null) {
        weeklyMenu.value = menu;
      } else {
        createDefaultWeeklyMenu();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load menu: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void createDefaultWeeklyMenu() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final List<DayMenu> dayMenus = [];

    for (int i = 0; i < days.length; i++) {
      final bool isWeekend = i >= 5;

      List<Meal> meals = [
        Meal(
          id: 'breakfast_${days[i].toLowerCase()}',
          name: 'Breakfast',
          startTime: TimeOfDay(hour: isWeekend ? 8 : 7, minute: 30),
          endTime: TimeOfDay(hour: isWeekend ? 10 : 9, minute: 0),
        ),
        Meal(
          id: 'lunch_${days[i].toLowerCase()}',
          name: 'Lunch',
          startTime: TimeOfDay(hour: isWeekend ? 13 : 12, minute: 30),
          endTime: TimeOfDay(hour: isWeekend ? 14 : 13, minute: 30),
        ),
        Meal(
          id: 'snacks_${days[i].toLowerCase()}',
          name: 'Snacks',
          startTime: TimeOfDay(hour: 17, minute: 30),
          endTime: TimeOfDay(hour: 18, minute: 0),
        ),
        Meal(
          id: 'dinner_${days[i].toLowerCase()}',
          name: 'Dinner',
          startTime: TimeOfDay(hour: 20, minute: 0),
          endTime: TimeOfDay(hour: 21, minute: 0),
        ),
      ];

      dayMenus.add(DayMenu(
        id: days[i].toLowerCase(),
        name: days[i],
        isWeekend: isWeekend,
        meals: meals,
      ));
    }

    weeklyMenu.value = WeeklyMenu(
      id: 'weekly_menu_${hostelId.value}',
      hostelId: hostelId.value,
      days: dayMenus,
    );
  }

  void selectDay(String dayId) {
    selectedDayId.value = dayId;
    update();
  }

  void selectMeal(String mealId) {
    selectedMealId.value = mealId;
  }

  Future<void> updateMealItems(
      String dayId, String mealId, List<String> items) async {
    try {
      if (weeklyMenu.value == null) return;

      final menu = weeklyMenu.value!;
      final dayIndex = menu.days.indexWhere((day) => day.id == dayId);

      if (dayIndex == -1) return;

      final day = menu.days[dayIndex];
      final mealIndex = day.meals.indexWhere((meal) => meal.id == mealId);

      if (mealIndex == -1) return;

      // Create updated copies
      final updatedMeal = day.meals[mealIndex].copyWith(items: items);
      final updatedMeals = List<Meal>.from(day.meals);
      updatedMeals[mealIndex] = updatedMeal;

      final updatedDay = day.copyWith(meals: updatedMeals);
      final updatedDays = List<DayMenu>.from(menu.days);
      updatedDays[dayIndex] = updatedDay;

      weeklyMenu.value = WeeklyMenu(
        id: menu.id,
        hostelId: menu.hostelId,
        days: updatedDays,
      );

      await _repository.updateWeeklyMenu(weeklyMenu.value!);

      Get.snackbar(
        AppStrings.success,
        AppStrings.menuItemsUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to update meal items: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateMealTiming(String dayId, String mealId,
      TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      if (weeklyMenu.value == null) return;

      final menu = weeklyMenu.value!;
      final dayIndex = menu.days.indexWhere((day) => day.id == dayId);

      if (dayIndex == -1) return;

      final day = menu.days[dayIndex];
      final mealIndex = day.meals.indexWhere((meal) => meal.id == mealId);

      if (mealIndex == -1) return;

      // Create updated copies
      final updatedMeal = day.meals[mealIndex].copyWith(
        startTime: startTime,
        endTime: endTime,
      );

      final updatedMeals = List<Meal>.from(day.meals);
      updatedMeals[mealIndex] = updatedMeal;

      final updatedDay = day.copyWith(meals: updatedMeals);
      final updatedDays = List<DayMenu>.from(menu.days);
      updatedDays[dayIndex] = updatedDay;

      weeklyMenu.value = WeeklyMenu(
        id: menu.id,
        hostelId: menu.hostelId,
        days: updatedDays,
      );

      await _repository.updateWeeklyMenu(weeklyMenu.value!);

      Get.snackbar(
        AppStrings.success,
        AppStrings.mealTimingsUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to update meal timing: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveWeeklyMenu() async {
    try {
      if (weeklyMenu.value == null) return;

      isLoading.value = true;
      await _repository.updateWeeklyMenu(weeklyMenu.value!);

      Get.snackbar(
        AppStrings.success,
        AppStrings.messMenuUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to save menu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
