import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final DateTime date;
  final String mealType;
  final List<String> items;
  final String hostelId;

  Meal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.items,
    required this.hostelId,
  });

  factory Meal.fromMap(Map<String, dynamic> data, String docId) {
    return Meal(
      id: docId,
      date: (data['date'] as Timestamp).toDate(),
      mealType: data['mealType'] ?? '',
      items: List<String>.from(data['items'] ?? []),
      hostelId: data['hostelId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'items': items,
      'hostelId': hostelId,
    };
  }
}
