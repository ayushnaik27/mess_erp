import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final double ratePerUnit;
  final String categoryId;
  final String hostelId;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.ratePerUnit,
    required this.categoryId,
    required this.hostelId,
    required this.updatedAt,
  });

  factory Item.fromMap(Map<String, dynamic> data, String docId) {
    return Item(
      id: docId,
      name: data['name'] ?? '',
      ratePerUnit: (data['ratePerUnit'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ratePerUnit': ratePerUnit,
      'categoryId': categoryId,
      'hostelId': hostelId,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Item copyWith({
    String? id,
    String? name,
    double? ratePerUnit,
    String? categoryId,
    String? hostelId,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      categoryId: categoryId ?? this.categoryId,
      hostelId: hostelId ?? this.hostelId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
