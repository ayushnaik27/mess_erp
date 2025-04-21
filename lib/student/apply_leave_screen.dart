import 'dart:async';
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
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    int currentSystemTime = DateTime.now().hour;

    if (selectedFromDate.day == tomorrow.day) {
      if (currentSystemTime < 11) {
        setState(() {
          options = ['Breakfast', 'Lunch', 'Dinner'];
          selectedFromMeal = options[0];
          selectedToMeal = '';
          selectedToDate = selectedFromDate.add(const Duration(days: 1));
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
                child: const Text('OK'),
              )
            ],
          ),
        );
        return;
      }
    } else {
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
      ),
    );
  }

  // void showToMealOptions() {
  //   List<String> options = [];
  //   if (selectedFromDate.day == selectedToDate.day) {
  //     setState(() {
  //       options = ['Dinner'];
  //       selectedToMeal = options[0];
  //     });
  //   } else if (selectedToDate.day == selectedFromDate.day + 1 ||
  //       selectedToDate.month == selectedFromDate.month + 1 ||
  //       selectedToDate.year == selectedFromDate.year + 1) {
  //     setState(() {
  //       if (selectedFromMeal == 'Breakfast' || selectedFromMeal == 'Lunch') {
  //         options = ['Lunch', 'Dinner'];
  //       } else {
  //         options = ['Dinner'];
  //       }
  //       selectedToMeal = options[0];
  //     });
  //   } else {
  //     setState(() {
  //       options = ['Breakfast'];
  //       selectedToMeal = options[0];
  //     });
  //   }

  //   showAdaptiveDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Meal'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: options
  //             .map((e) => ListTile(
  //                   title: Text(e),
  //                   onTap: () {
  //                     setState(() {
  //                       selectedToMeal = e;
  //                     });
  //                     Navigator.of(context).pop();
  //                   },
  //                 ))
  //             .toList(),
  //       ),
  //     ),
  //   );
  // }

  void showToMealOptions() {
    List<String> allMeals = ['Breakfast', 'Lunch', 'Dinner'];
    List<String> options = [];

    // Determine the index of the selectedFromMeal in allMeals
    int fromMealIndex = allMeals.indexOf(selectedFromMeal);

    // Handle case when selectedToDate is the same as selectedFromDate
    if (selectedFromDate.day == selectedToDate.day &&
        selectedFromDate.month == selectedToDate.month &&
        selectedFromDate.year == selectedToDate.year) {
      options = ['Dinner'];
    }
    // Handle case when selectedToDate is the day immediately following selectedFromDate
    else if (selectedToDate.isAfter(selectedFromDate) &&
        selectedToDate
            .isBefore(selectedFromDate.add(const Duration(days: 2)))) {
      if (selectedFromMeal == 'Breakfast') {
        options = allMeals;
      } else if (selectedFromMeal == 'Lunch') {
        options = ['Breakfast', 'Lunch', 'Dinner'];
      } else {
        options = ['Dinner'];
      }
    }
    // Handle case when selectedToDate spans multiple days
    else {
      options = allMeals;
    }

    // Set the default selectedToMeal to the first option
    setState(() {
      selectedToMeal = options[0];
    });

    // Show the meal options dialog
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apply for Leave',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text(
                  'From Date: ',
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(selectedFromDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: selectedFromDate,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
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
                  },
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'From Meal: ',
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Text(
                    selectedFromMeal,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: showFromMealOptions,
                  icon: const Icon(Icons.edit),
                )
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'To Date: ',
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(selectedToDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
                const Text(
                  'To Meal: ',
                  style: TextStyle(fontSize: 18),
                ),
                Expanded(
                  child: Text(
                    selectedToMeal,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
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
                      .username,
                ).then((value) {
                  if (!value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Invalid Selection'),
                          content: const Text(
                            'You cannot apply for leave before your last leave date. Please select another date.',
                          ),
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Leave request submitted successfully!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Submit Leave Request',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _submitLeaveRequest(String rollNumber) async {
    try {
      QuerySnapshot leaveDetailSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('leaveDetails')
          .get();

      if (leaveDetailSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot lastLeaveDetailSnapshot =
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

      List<DateTime> datesToApply = [];

      for (DateTime date = selectedFromDate;
          date.isBefore(selectedToDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        datesToApply.add(date);
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DateTime date in datesToApply) {
        List<String> onLeaveMeals = [];
        if (date == selectedFromDate) {
          onLeaveMeals.addAll(fromMealOptions
              .sublist(fromMealOptions.indexOf(selectedFromMeal)));
        } else if (date == selectedToDate) {
          onLeaveMeals.addAll(toMealOptions.sublist(
              0, toMealOptions.indexOf(selectedToMeal) + 1));
        } else {
          onLeaveMeals.addAll(toMealOptions);
        }

        String leaveDate = DateFormat('dd-MM-yyyy').format(date);

        DocumentReference newLeaveDocRef = FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('newLeaveDetails')
            .doc(leaveDate);

        batch.set(
          newLeaveDocRef,
          {
            'date': leaveDate,
            'onLeaveMeals': onLeaveMeals,
            'timestamp': date,
            'fromDate': DateFormat('dd-MM-yyyy').format(selectedFromDate),
            'toDate': DateFormat('dd-MM-yyyy').format(selectedToDate),
          },
          SetOptions(merge: true),
        );

        DocumentReference leaveDetailDocRef = FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('leaveDetails')
            .doc();

        batch.set(
          leaveDetailDocRef,
          {
            'day': date.day,
            'month': date.month,
            'year': date.year,
            'onLeave': true,
            'leaveCount': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return true;
    } catch (e, stackTrace) {
      log('Error submitting leave request: $e', stackTrace: stackTrace);
      return false;
    }
  }
}
