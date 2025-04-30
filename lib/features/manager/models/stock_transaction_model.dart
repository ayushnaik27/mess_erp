import 'package:cloud_firestore/cloud_firestore.dart';

class StockTransaction {
  final String id;
  final String itemId;
  final String itemName;
  final String hostelId;
  final int quantity;
  final double amount;
  final String type;
  final DateTime date;
  final String issuedTo;

  StockTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.hostelId,
    required this.quantity,
    required this.amount,
    required this.type,
    required this.date,
    this.issuedTo = 'mess',
  });

  factory StockTransaction.fromMap(Map<String, dynamic> data, String docId) {
    return StockTransaction(
      id: docId,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      hostelId: data['hostelId'] ?? '',
      quantity: data['quantity'] ?? 0,
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      issuedTo: data['issuedTo'] ?? 'mess',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'hostelId': hostelId,
      'quantity': quantity,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'issuedTo': issuedTo,
    };
  }
}
