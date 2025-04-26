import 'package:cloud_firestore/cloud_firestore.dart';

class MealOptOut {
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool snacks;
  final bool dinner;

  MealOptOut({
    required this.date,
    this.breakfast = true,
    this.lunch = true,
    this.snacks = true,
    this.dinner = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'breakfast': breakfast,
      'lunch': lunch,
      'snacks': snacks,
      'dinner': dinner,
    };
  }

  factory MealOptOut.fromJson(Map<String, dynamic> json) {
    return MealOptOut(
      date: (json['date'] as Timestamp).toDate(),
      breakfast: json['breakfast'] ?? false,
      lunch: json['lunch'] ?? false,
      snacks: json['snacks'] ?? false,
      dinner: json['dinner'] ?? false,
    );
  }
}
