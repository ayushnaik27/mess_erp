import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const routeName = '/applyLeave';

  const ApplyLeaveScreen({super.key});
  @override
  _ApplyLeaveScreenState createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  DateTime selectedFromDate =
      DateTime.now().add(const Duration(days: 1)); // Starting from tomorrow
  String selectedFromMeal = '';
  DateTime selectedToDate = DateTime.now().add(const Duration(days: 2));

  String selectedToMeal = '';
  List<String> fromMealOptions = ['Breakfast', 'Lunch', 'Dinner'];
  List<String> toMealOptions = ['Breakfast', 'Lunch', 'Dinner'];

  void showFromMealOptions() {
    List<String> options = [];
    DateTime tommorrow = DateTime.now().add(const Duration(days: 1));
    if (selectedFromDate.day == tommorrow.day) {
      print('I am here');
      int currentSystemTime = DateTime.now().hour;
      if (currentSystemTime < 11) {
        setState(() {
          options = ['Breakfast', 'Lunch', 'Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate;
        });
      } else if (currentSystemTime < 15) {
        setState(() {
          options = ['Lunch', 'Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
        });
      } else if (currentSystemTime < 22) {
        setState(() {
          options = ['Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cannot apply for leave'),
            content: const Text('You cannot apply for leave after 10pm'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          ),
        );
      }
    } else {
      print('I am here 2');
      setState(() {
        options = ['Breakfast', 'Lunch', 'Dinner'];
        selectedFromMeal = options[0];
        selectedToMeal = '';
        selectedToDate = selectedFromDate;
      });
    }

    showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Select Meal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map((e) => ListTile(
                          title: Text(e),
                          onTap: () {
                            setState(() {
                              selectedFromMeal = e;
                            });
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
              ),
            ));
  }

  void showToMealOptions() {
    List<String> options = [];
    if (selectedFromDate.day == selectedToDate.day) {
      setState(() {
        options = ['Dinner'];
        selectedToMeal = options[0];
      });
    } else if (selectedToDate.day == selectedFromDate.day + 1 ||
        selectedToDate.month == selectedFromDate.month + 1 ||
        selectedToDate.year == selectedFromDate.year + 1) {
      print("I guuess i am here");
      setState(() {
        if (selectedFromMeal == 'Breakfast') {
          options = ['Breakfast', 'Lunch', 'Dinner'];
        } else if (selectedFromMeal == 'Lunch') {
          options = ['Breakfast', 'Lunch', 'Dinner'];
        } else {
          options = ['Lunch', 'Dinner'];
        }
        selectedToMeal = options[0];
      });
    } else {
      setState(() {
        options = ['Breakfast'];
        selectedToMeal = options[0];
      });
    }

    showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Select Meal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: options
                    .map((e) => ListTile(
                          title: Text(e),
                          onTap: () {
                            setState(() {
                              selectedToMeal = e;
                            });
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
              ),
            ));
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
                const Text('From Date: '),
                Expanded(
                  child:
                      Text(DateFormat('dd-MM-yyyy').format(selectedFromDate)),
                ),
                IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: selectedFromDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 5)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            selectedFromDate = value;
                            selectedFromMeal = '';
                            selectedToMeal = '';
                            selectedToDate = selectedFromDate;
                          });
                        }
                      });
                    }),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text('From Meal: '),
                Expanded(child: Text(selectedFromMeal)),
                IconButton(
                    onPressed: showFromMealOptions, icon: Icon(Icons.edit))
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text('To Date: '),
                Expanded(
                  child: Text(DateFormat('dd-MM-yyyy').format(selectedToDate)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    DateTime firstDate = selectedFromMeal == 'Breakfast'
                        ? selectedFromDate
                        : selectedFromDate.add(const Duration(days: 1));
                    showDatePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      initialDate: firstDate,
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedToDate = value;
                        });
                      }
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text('To Meal: '),
                Expanded(child: Text(selectedToMeal)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: showToMealOptions,
                ),
              ],
            ),
            const Divider(),
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

      if (selectedFromDate.isBefore(lastLeaveDate)) {
        return false;
      }
    }

    for (DateTime date = selectedFromDate;
        date.isBefore(selectedToDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      int i = 0;
      final String year = date.year.toString();
      final String month = date.month.toString();
      final String day = date.day.toString();
      final String docId = (leaveDetailSnapshot.docs.length + 1).toString();

      List<String> onLeaveMeals = date == selectedFromDate
          ? fromMealOptions.sublist(fromMealOptions.indexOf(selectedFromMeal))
          : date == selectedToDate
              ? toMealOptions.sublist(
                  0, toMealOptions.indexOf(selectedToMeal) + 1)
              : toMealOptions;
      log('Date: $date');
      log('On Leave Meals: $onLeaveMeals');

      String leaveDate = DateFormat('dd-MM-yyyy').format(date);

      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('newLeaveDetails')
          .doc(leaveDate)
          .set({
        'date': leaveDate,
        'onLeaveMeals': onLeaveMeals,
        'timestamp': date,
        'fromDate': DateFormat('dd-MM-yyyy').format(selectedFromDate),
        'toDate': DateFormat('dd-MM-yyyy').format(selectedToDate),
      }, SetOptions(merge: true));

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
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave request submitted successfully!'),
      ),
    );
    return true;
  }
}
