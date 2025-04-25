import 'package:mess_erp/features/committee/models/day_menu_model.dart';

class WeeklyMenu {
  final String id;
  final String hostelId;
  final List<DayMenu> days;

  WeeklyMenu({
    required this.id,
    required this.hostelId,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  factory WeeklyMenu.fromJson(Map<String, dynamic> json) {
    return WeeklyMenu(
      id: json['id'],
      hostelId: json['hostelId'],
      days: (json['days'] as List)
          .map((dayJson) => DayMenu.fromJson(dayJson))
          .toList(),
    );
  }

  WeeklyMenu copyWith({
    String? id,
    String? hostelId,
    List<DayMenu>? days,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      days: days ?? this.days,
    );
  }
}
