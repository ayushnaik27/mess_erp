import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityLog {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  ActivityLog({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  String getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    String prefix;
    if (activityDate == today) {
      prefix = 'Today';
    } else if (activityDate == yesterday) {
      prefix = 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }

    return '$prefix, ${DateFormat('h:mm a').format(timestamp)}';
  }
}
