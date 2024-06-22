import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TrackLeavesScreen extends StatefulWidget {
  final String studentRollNumber;

  const TrackLeavesScreen({Key? key, required this.studentRollNumber})
      : super(key: key);

  @override
  _TrackLeavesScreenState createState() => _TrackLeavesScreenState();
}

class _TrackLeavesScreenState extends State<TrackLeavesScreen> {
  late Map<String, List<String>> leaveRecords;
  late DateTime focusedDay;
  DateTime? selectedDay;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    focusedDay = DateTime.now();
    leaveRecords = {};
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .doc(widget.studentRollNumber)
        .collection('newLeaveDetails')
        .get();

    Map<String, List<String>> fetchedLeaves = {};

    for (QueryDocumentSnapshot leave in leaveSnapshot.docs) {
      fetchedLeaves[leave.id] = List<String>.from(leave['onLeaveMeals']);
    }

    setState(() {
      leaveRecords = fetchedLeaves;
      loading = false;
    });
  }

  Color getDayColor(DateTime day) {
    String dayString = DateFormat('dd-MM-yyyy').format(day);
    if (!leaveRecords.containsKey(dayString)) {
      return Colors.green; // No leave
    } else if (leaveRecords[dayString]!.length == 3) {
      return Colors.red; // Full leave
    } else {
      return Colors.orange; // Partial leave
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Leaves'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      this.selectedDay = selectedDay;
                      this.focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: getDayColor(day),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LegendItem(color: Colors.green, text: 'No Leave'),
                      SizedBox(width: 10),
                      LegendItem(color: Colors.red, text: 'Full Leave'),
                      SizedBox(width: 10),
                      LegendItem(color: Colors.orange, text: 'Partial Leave'),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: selectedDay == null
                      ? const Center(child: Text('Select a day to see details'))
                      : buildDayDetails(selectedDay!),
                ),
              ],
            ),
    );
  }

  Widget buildDayDetails(DateTime day) {
    String dayString = DateFormat('dd-MM-yyyy').format(day);
    List<String> onLeaveMeals = leaveRecords[dayString] ?? [];

    log(leaveRecords.toString());

    return ListView(
      children: [
        ListTile(
          title: Text(DateFormat('dd-MM-yyyy').format(day)),
          subtitle: onLeaveMeals.isNotEmpty
              ? Text('On leave for meals: ${onLeaveMeals.join(', ')}')
              : const Text('Not on leave'),
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
