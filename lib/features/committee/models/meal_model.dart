import 'package:flutter/material.dart';

class Meal {
  final String id;
  final String name; // Breakfast, Lunch, etc.
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> items;

  Meal({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.items = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'items': items,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      items: List<String>.from(json['items'] ?? []),
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<String>? items,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      items: items ?? this.items,
    );
  }
}
