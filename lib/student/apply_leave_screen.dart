import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const routeName = '/applyLeave';

  const ApplyLeaveScreen({super.key});
  @override
  _ApplyLeaveScreenState createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  DateTime fromDate =
      DateTime.now().add(const Duration(days: 1)); // Starting from tomorrow
  String fromMeal = 'Breakfast';
  DateTime toDate =
      DateTime.now().add(const Duration(days: 2)); // Default to next day
  String toMeal = 'Dinner';

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  void _selectFromMeal() {
    DateTime now = DateTime.now();
    List<String> mealOptions = [];

    if (fromDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      if (now.hour < 10) {
        mealOptions = ['Breakfast', 'Lunch', 'Dinner'];
      } else if (now.hour < 15) {
        mealOptions = ['Lunch', 'Dinner'];
      } else if (now.hour < 22) {
        mealOptions = ['Dinner'];
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Invalid Selection'),
              content: const Text(
                  'You cannot turn the mess off from tomorrow. Please select some other date.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    } else {
      mealOptions = ['Breakfast', 'Lunch', 'Dinner'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select From Meal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: mealOptions.map((meal) {
              return ListTile(
                title: Text(meal),
                onTap: () {
                  setState(() {
                    fromMeal = meal;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _selectToDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime fromDate = this.fromDate;

    // If the selected "From Meal" is breakfast, show dates starting from fd; else, show dates starting from fd + 1
    if (fromMeal == 'Breakfast') {
      fromDate = fromDate;
    } else {
      fromDate = fromDate.add(const Duration(days: 1));
    }

    DateTime? toDate = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: fromDate,
      lastDate: DateTime(currentDate.year + 1),
    );

    if (toDate != null) {
      setState(() {
        this.toDate = toDate;
      });
    }
  }

  void _selectToMeal() {
    DateTime fromDate = this.fromDate;
    DateTime toDate = this.toDate;

    List<String> mealOptions = [
      'Breakfast',
      'Lunch',
      'Dinner',
    ];

    // If the "From Date" is the same as the "To Date"
    if (fromDate.isAtSameMomentAs(toDate)) {
      setState(() {
        toMeal = 'Dinner'; // Set "To Meal" to dinner
        mealOptions = ['Dinner'];
      });
    }
    // If "To Date" is the day after "From Date"
    else if (fromDate.add(const Duration(days: 1)).isAtSameMomentAs(toDate)) {
      // Allow selecting any meal from "From Meal" to all meals
      // For simplicity, let's assume meal options are stored in a List<String> called mealOptions
      _showToMealOptions(mealOptions);
    }
    // For other cases
    else {
      setState(() {
        toMeal = 'Breakfast'; // Set "To Meal" to breakfast
      });
    }
  }

// Method to show meal options and handle selection
  void _showToMealOptions(List<String> mealOptions) async {
    String? selectedToMeal = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select To Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: mealOptions.map((meal) {
            return ListTile(
              title: Text(meal),
              onTap: () {
                Navigator.of(context).pop(meal);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selectedToMeal != null) {
      setState(() {
        toMeal = selectedToMeal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Leave'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                        'From Date: ${DateFormat('dd-MM-yyyy').format(fromDate)}')),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectFromDate(context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('From Meal: $fromMeal')),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectFromMeal(),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text(
                        'To Date: ${DateFormat('dd-MM-yyyy').format(toDate)}')),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectToDate(context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('To Meal: $toMeal')),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectToMeal(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _submitLeaveRequest(
                        Provider.of<UserProvider>(context, listen: false)
                            .user
                            .username)
                    .then((value) {
                  return value
                      ? Navigator.of(context).pop()
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Invalid Selection'),
                              content: const Text(
                                  'You cannot apply for leave before your last leave date. Please select some other date.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                });
              },
              child: const Text('Submit Leave Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _submitLeaveRequest(String rollNumber) async {
    // LeaveRequest leaveRequest = LeaveRequest(
    //   fromDate: fromDate,
    //   fromMeal: fromMeal,
    //   toDate: toDate,
    //   toMeal: toMeal,
    // );

    QuerySnapshot<Map<String, dynamic>> leaveDetailSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('leaveDetails')
            .get();

    if (leaveDetailSnapshot.docs.isNotEmpty) {
      print('Hello');
      QueryDocumentSnapshot<Map<String, dynamic>> lastLeaveDetailSnapshot =
          leaveDetailSnapshot.docs.last;

      DateTime lastLeaveDate = DateTime(
        lastLeaveDetailSnapshot['year'],
        lastLeaveDetailSnapshot['month'],
        lastLeaveDetailSnapshot['day'],
      );

      if (fromDate.isBefore(lastLeaveDate)) {
        return false;
      }
    }

    for (DateTime date = fromDate;
        date.isBefore(toDate);
        date = date.add(const Duration(days: 1))) {
      final String docId = (leaveDetailSnapshot.docs.length + 1).toString();

      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('leaveDetails')
          .doc(docId)
          .set({
        'day': date.day,
        'month': date.month,
        'year': date.year,
        'onLeave': true,
        'leaveCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
        ),
      );
    }
    return true;
  }
}
