import 'package:cloud_firestore/cloud_firestore.dart';

class ExtraItem {
  final String id;
  final String studentId;
  final String rollNumber;
  final String itemName;
  final double amount;
  final DateTime date;
  final String status;
  final String hostelId;
  final String approvedBy;

  ExtraItem({
    required this.id,
    required this.studentId,
    required this.rollNumber,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.status,
    required this.hostelId,
    this.approvedBy = '',
  });

  factory ExtraItem.fromMap(Map<String, dynamic> data, String docId) {
    return ExtraItem(
      id: docId,
      studentId: data['studentId'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      itemName: data['itemName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      hostelId: data['hostelId'] ?? '',
      approvedBy: data['approvedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'rollNumber': rollNumber,
      'itemName': itemName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'hostelId': hostelId,
      'approvedBy': approvedBy,
    };
  }
}
