import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String vendorId;
  final String vendorName;
  final double totalAmount;
  final DateTime dateGenerated;
  final List<String> billIds;
  final String status;
  final String approvedBy;
  final String hostelId;
  final String notes;

  Voucher({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.totalAmount,
    required this.dateGenerated,
    required this.billIds,
    required this.status,
    required this.hostelId,
    this.approvedBy = '',
    this.notes = '',
  });

  factory Voucher.fromMap(Map<String, dynamic> data, String docId) {
    return Voucher(
      id: docId,
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      dateGenerated: (data['dateGenerated'] as Timestamp).toDate(),
      billIds: List<String>.from(data['billIds'] ?? []),
      status: data['status'] ?? 'pending',
      approvedBy: data['approvedBy'] ?? '',
      hostelId: data['hostelId'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'totalAmount': totalAmount,
      'dateGenerated': Timestamp.fromDate(dateGenerated),
      'billIds': billIds,
      'status': status,
      'approvedBy': approvedBy,
      'hostelId': hostelId,
      'notes': notes,
    };
  }
}
