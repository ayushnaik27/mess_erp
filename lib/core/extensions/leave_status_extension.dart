import 'package:flutter/material.dart';
import 'package:mess_erp/core/enums/leave_status.dart';

extension LeaveStatusExtension on LeaveStatus {
  String get displayText {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return Colors.amber;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }
}
