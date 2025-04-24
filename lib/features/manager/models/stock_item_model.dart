import 'package:cloud_firestore/cloud_firestore.dart';

class StockItem {
  final String id;
  final String name;
  final String categoryId;
  final String hostelId;
  final int quantity;
  final double ratePerUnit;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.hostelId,
    required this.quantity,
    required this.ratePerUnit,
    required this.updatedAt,
  });

  factory StockItem.fromMap(Map<String, dynamic> data, String docId) {
    return StockItem(
      id: docId,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      hostelId: data['hostelId'] ?? '',
      quantity: data['quantity'] ?? 0,
      ratePerUnit: (data['ratePerUnit'] ?? 0.0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'hostelId': hostelId,
      'quantity': quantity,
      'ratePerUnit': ratePerUnit,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate balance value
  double get balance => quantity * ratePerUnit;

  // Create a copy with updated values
  StockItem copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? hostelId,
    int? quantity,
    double? ratePerUnit,
    DateTime? updatedAt,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      hostelId: hostelId ?? this.hostelId,
      quantity: quantity ?? this.quantity,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
