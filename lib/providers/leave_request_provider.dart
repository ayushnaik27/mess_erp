class LeaveRequest {
  final DateTime fromDate;
  final String fromMeal;
  final DateTime toDate;
  final String toMeal;

  LeaveRequest({
    required this.fromDate,
    required this.fromMeal,
    required this.toDate,
    required this.toMeal,
  });
}