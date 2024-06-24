import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<List<Map<String, dynamic>>> getStudentsOnLeave() async {
  DateTime currentTime = DateTime.now();
  List<Map<String, dynamic>> studentsOnLeave = [];

  QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
      .collection('loginCredentials')
      .doc('roles')
      .collection('student')
      .get();

  DateTime today =
      DateTime(currentTime.year, currentTime.month, currentTime.day);

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
      Map<String, dynamic> leaveData =
          leaveSnapshot.data() as Map<String, dynamic>;
      studentsOnLeave.add({
        'rollNumber': studentDoc.id,
        'meals': leaveData['onLeaveMeals'],
      });
    }
  });

  return studentsOnLeave;
}

class StudentsOnLeaveScreen extends StatefulWidget {
  @override
  State<StudentsOnLeaveScreen> createState() => _StudentsOnLeaveScreenState();
}

class _StudentsOnLeaveScreenState extends State<StudentsOnLeaveScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students on Leave'),
        actions: [Text(DateFormat('dd-MM-yyyy').format(DateTime.now()))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Roll Number',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getStudentsOnLeave(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null) {
                  return const Center(child: Text('No students on leave'));
                }

                List<Map<String, dynamic>> studentsOnLeave = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  studentsOnLeave = studentsOnLeave
                      .where((student) =>
                          student['rollNumber'].contains(_searchQuery))
                      .toList();
                }

                if (studentsOnLeave.isEmpty) {
                  return const Center(child: Text('No students on leave'));
                }

                return ListView.builder(
                  itemCount: studentsOnLeave.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> studentData = snapshot.data![index];
                    String rollNumber = studentData['rollNumber'];
                    List<dynamic> mealsDynamic = studentData['meals'];
                    List<String> meals =
                        mealsDynamic.map((e) => e.toString()).toList();

                    return ListTile(
                        title: Text(
                          'Roll Number: $rollNumber',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          'Meals: ${meals.join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
