import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/enums/leave_status.dart';
import 'package:mess_erp/features/student/models/meal_opt_out_model.dart';

class LeaveApplication {
  final String? id;
  final String studentId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? comments;
  final List<MealOptOut> mealsOptedOut;

  LeaveApplication({
    this.id,
    required this.studentId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveStatus.approved,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.comments,
    required this.mealsOptedOut,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'comments': comments,
      'mealsOptedOut': mealsOptedOut.map((meal) => meal.toJson()).toList(),
    };
  }

  /// Create a model from Firestore document
  factory LeaveApplication.fromJson(Map<String, dynamic> json, String docId) {
    return LeaveApplication(
      id: docId,
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      reason: json['reason'] ?? '',
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeaveStatus.pending,
      ),
      appliedAt: (json['appliedAt'] as Timestamp).toDate(),
      reviewedAt: json['reviewedAt'] != null
          ? (json['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewedBy: json['reviewedBy'],
      comments: json['comments'],
      mealsOptedOut: (json['mealsOptedOut'] as List<dynamic>?)
              ?.map((mealJson) => MealOptOut.fromJson(mealJson))
              .toList() ??
          [],
    );
  }

  LeaveApplication copyWith({
    String? id,
    String? studentId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? comments,
    List<MealOptOut>? mealsOptedOut,
  }) {
    return LeaveApplication(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      comments: comments ?? this.comments,
      mealsOptedOut: mealsOptedOut ?? this.mealsOptedOut,
    );
  }
}
