import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextThreeMealsScreen extends StatefulWidget {
  @override
  _NextThreeMealsScreenState createState() => _NextThreeMealsScreenState();
}

Future<Map<String, Map<String, dynamic>>>
    fetchNumberOfStudentsForNextThreeMeals() async {
  Map<String, Map<String, dynamic>> data = {
    'Meal1': {'Date': DateTime.now(), 'MealType': '', 'NumStudents': 0},
    'Meal2': {'Date': DateTime.now(), 'MealType': '', 'NumStudents': 0},
    'Meal3': {'Date': DateTime.now(), 'MealType': '', 'NumStudents': 0}
  };
  // Fetch the number of students for the next three meals
  int meal1 = 0, meal2 = 0, meal3 = 0;
  String mealType1 = '', mealType2 = '', mealType3 = '';
  DateTime meal1Date = DateTime.now(),
      meal2Date = DateTime.now(),
      meal3Date = DateTime.now();

  DateTime currentTime = DateTime.now();
  int numStudentForNextThreeMeals = 0;
  QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
      .collection('loginCredentials')
      .doc('roles')
      .collection('student')
      .get();

  int totalStudents = studentSnapshot.docs.length * 3;

  if (currentTime.hour < 10) {
    mealType1 = 'Breakfast';
    mealType2 = 'Lunch';
    mealType3 = 'Dinner';
    meal1Date = DateTime(currentTime.year, currentTime.month, currentTime.day);
    meal2Date = meal1Date;
    meal3Date = meal1Date;

    // Fetch the number of students for the breakfast, lunch, and dinner of that day
    DateTime today =
        DateTime(currentTime.year, currentTime.month, currentTime.day);

    // Iterate over all students
    await Future.forEach(studentSnapshot.docs, (studentDoc) async {
      DocumentSnapshot leaveSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(today))
          .get();

      if (leaveSnapshot.exists) {
        // Check if the student is on leave for any meal
        Map<String, dynamic> leaveData =
            leaveSnapshot.data() as Map<String, dynamic>;
        if (leaveData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveData['onLeaveMeals'];
          if (onLeaveMeals.contains('Breakfast')) {
            meal1++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Lunch')) {
            meal2++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Dinner')) {
            meal3++;
            numStudentForNextThreeMeals--;
          }
        }
      }
    });

    // Calculate the final count by subtracting from the total number of students
    numStudentForNextThreeMeals = totalStudents + numStudentForNextThreeMeals;
  } else if (currentTime.hour < 15) {
    mealType1 = 'Lunch';
    mealType2 = 'Dinner';
    mealType3 = 'Breakfast';
    meal1Date = DateTime(currentTime.year, currentTime.month, currentTime.day);
    meal2Date = meal1Date;
    meal3Date = meal1Date.add(const Duration(days: 1));
    // Similar logic for lunch, dinner of the current day and breakfast of the next day
    DateTime today =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    // Iterate over all students
    await Future.forEach(studentSnapshot.docs, (studentDoc) async {
      DocumentSnapshot leaveTodaySnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(today))
          .get();

      DocumentSnapshot leaveTomorrowSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(tomorrow))
          .get();

      if (leaveTodaySnapshot.exists) {
        // Check if the student is on leave for any meal of today
        Map<String, dynamic> leaveTodayData =
            leaveTodaySnapshot.data() as Map<String, dynamic>;
        if (leaveTodayData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveTodayData['onLeaveMeals'];
          if (onLeaveMeals.contains('Lunch')) {
            meal1++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Dinner')) {
            meal2++;
            numStudentForNextThreeMeals--;
          }
        }
      }
      if (leaveTomorrowSnapshot.exists) {
        // Check if the student is on leave for breakfast of tomorrow
        Map<String, dynamic> leaveTomorrowData =
            leaveTomorrowSnapshot.data() as Map<String, dynamic>;
        if (leaveTomorrowData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveTomorrowData['onLeaveMeals'];
          if (onLeaveMeals.contains('Breakfast')) {
            meal3++;
            numStudentForNextThreeMeals--;
          }
        }
      }
    });

    // Calculate the final count by subtracting from the total number of students
    numStudentForNextThreeMeals = totalStudents + numStudentForNextThreeMeals;
  } else if (currentTime.hour < 22) {
    mealType1 = 'Dinner';
    mealType2 = 'Breakfast';
    mealType3 = 'Lunch';
    meal1Date = DateTime(currentTime.year, currentTime.month, currentTime.day);
    meal2Date = meal1Date.add(const Duration(days: 1));
    meal3Date = meal1Date.add(const Duration(days: 1));

    // Similar logic for dinner of the current day and breakfast, lunch of the next day
    DateTime today =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    // Iterate over all students
    await Future.forEach(studentSnapshot.docs, (studentDoc) async {
      DocumentSnapshot leaveTodaySnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(today))
          .get();

      DocumentSnapshot leaveTomorrowSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(tomorrow))
          .get();

      if (leaveTodaySnapshot.exists) {
        // Check if the student is on leave for dinner of today
        Map<String, dynamic> leaveTodayData =
            leaveTodaySnapshot.data() as Map<String, dynamic>;
        if (leaveTodayData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveTodayData['onLeaveMeals'];
          if (onLeaveMeals.contains('Dinner')) {
            meal1++;
            numStudentForNextThreeMeals--;
          }
        }
      }
      if (leaveTomorrowSnapshot.exists) {
        // Check if the student is on leave for breakfast, lunch of tomorrow
        Map<String, dynamic> leaveTomorrowData =
            leaveTomorrowSnapshot.data() as Map<String, dynamic>;
        if (leaveTomorrowData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveTomorrowData['onLeaveMeals'];
          if (onLeaveMeals.contains('Breakfast')) {
            meal2++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Lunch')) {
            meal3++;
            numStudentForNextThreeMeals--;
          }
        }
      }
    });

    // Calculate the final count by subtracting from the total number of students
    numStudentForNextThreeMeals = totalStudents + numStudentForNextThreeMeals;
  } else {
    mealType1 = 'Breakfast';
    mealType2 = 'Lunch';
    mealType3 = 'Dinner';
    meal1Date = DateTime(currentTime.year, currentTime.month, currentTime.day)
        .add(const Duration(days: 1));
    meal2Date = meal1Date;
    meal3Date = meal1Date;

    // Similar logic for breakfast, lunch, dinner of the next day
    DateTime tomorrow = currentTime.add(const Duration(days: 1));

    // Iterate over all students
    await Future.forEach(studentSnapshot.docs, (studentDoc) async {
      DocumentSnapshot leaveTomorrowSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(studentDoc.id) // Using student ID instead of widget.rollNumber
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(tomorrow))
          .get();

      // Check if the student is on leave for any meal of tomorrow
      if (leaveTomorrowSnapshot.exists) {
        Map<String, dynamic> leaveTomorrowData =
            leaveTomorrowSnapshot.data() as Map<String, dynamic>;
        if (leaveTomorrowData.containsKey('onLeaveMeals')) {
          List<String> onLeaveMeals = leaveTomorrowData['onLeaveMeals'];
          if (onLeaveMeals.contains('Breakfast')) {
            meal1++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Lunch')) {
            meal2++;
            numStudentForNextThreeMeals--;
          }
          if (onLeaveMeals.contains('Dinner')) {
            meal3++;
            numStudentForNextThreeMeals--;
          }
        }
      }
    });

    // Calculate the final count by subtracting from the total number of students
    numStudentForNextThreeMeals = totalStudents + numStudentForNextThreeMeals;
  }
  log('Meal 1: $meal1, Meal 2: $meal2, Meal 3: $meal3');
  data['Meal1']!['NumStudents'] = totalStudents - meal1;
  data['Meal2']!['NumStudents'] = totalStudents - meal2;
  data['Meal3']!['NumStudents'] = totalStudents - meal3;
  data['Meal1']!['MealType'] = mealType1;
  data['Meal2']!['MealType'] = mealType2;
  data['Meal3']!['MealType'] = mealType3;
  data['Meal1']!['Date'] = meal1Date;
  data['Meal2']!['Date'] = meal2Date;
  data['Meal3']!['Date'] = meal3Date;
  log(data.toString());
  return data;
}

class _NextThreeMealsScreenState extends State<NextThreeMealsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Next Three Meals'),
        ),
        body: FutureBuilder(
          future: fetchNumberOfStudentsForNextThreeMeals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Column(
                children: [
                  Text('Error: ${snapshot.error}'),
                  Text('${snapshot.stackTrace}')
                ],
              ));
            }
            if (snapshot.data == null) {
              return const Center(child: Text('Error: No data found'));
            }
            Map<String, Map<String, dynamic>> data =
                snapshot.data as Map<String, Map<String, dynamic>>;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: const [
                DataColumn(label: Text('Meal')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Meal Type')),
                DataColumn(label: Text('Number of Students')),
              ], rows: [
                DataRow(cells: [
                  const DataCell(Text('1')),
                  DataCell(Text(
                      DateFormat('dd-MM-yyyy').format(data['Meal1']!['Date']))),
                  DataCell(Text(data['Meal1']!['MealType'])),
                  DataCell(Text(data['Meal1']!['NumStudents'].toString())),
                ]),
                DataRow(cells: [
                  const DataCell(Text('2')),
                  DataCell(Text(
                      DateFormat('dd-MM-yyyy').format(data['Meal2']!['Date']))),
                  DataCell(Text(data['Meal2']!['MealType'])),
                  DataCell(Text(data['Meal2']!['NumStudents'].toString())),
                ]),
                DataRow(cells: [
                  const DataCell(Text('3')),
                  DataCell(Text(
                      DateFormat('dd-MM-yyyy').format(data['Meal3']!['Date']))),
                  DataCell(Text(data['Meal3']!['MealType'])),
                  DataCell(Text(data['Meal3']!['NumStudents'].toString())),
                ]),
              ]),
            );
          },
        ));
  }
}
