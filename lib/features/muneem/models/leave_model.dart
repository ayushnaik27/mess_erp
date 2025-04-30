import 'package:cloud_firestore/cloud_firestore.dart';

class Leave {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String hostelId;

  Leave({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.hostelId,
  });

  factory Leave.fromMap(Map<String, dynamic> data, String docId) {
    return Leave(
      id: docId,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      hostelId: data['hostelId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': status,
      'hostelId': hostelId,
    };
  }
}
