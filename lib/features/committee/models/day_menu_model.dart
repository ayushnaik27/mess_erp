import 'package:mess_erp/features/committee/models/meal_model.dart';

class DayMenu {
  final String id;
  final String name; // Monday, Tuesday, etc.
  final bool isWeekend;
  final List<Meal> meals;

  DayMenu({
    required this.id,
    required this.name,
    required this.isWeekend,
    required this.meals,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isWeekend': isWeekend,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }

  factory DayMenu.fromJson(Map<String, dynamic> json) {
    return DayMenu(
      id: json['id'],
      name: json['name'],
      isWeekend: json['isWeekend'] ?? false,
      meals: (json['meals'] as List)
          .map((mealJson) => Meal.fromJson(mealJson))
          .toList(),
    );
  }

  DayMenu copyWith({
    String? id,
    String? name,
    bool? isWeekend,
    List<Meal>? meals,
  }) {
    return DayMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      isWeekend: isWeekend ?? this.isWeekend,
      meals: meals ?? this.meals,
    );
  }
}
