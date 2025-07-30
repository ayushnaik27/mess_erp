import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class StudentsOnLeaveScreen extends StatefulWidget {
  const StudentsOnLeaveScreen({super.key});

  @override
  State<StudentsOnLeaveScreen> createState() => _StudentsOnLeaveScreenState();
}

class _StudentsOnLeaveScreenState extends State<StudentsOnLeaveScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  Stream<List<Map<String, dynamic>>> fetchStudentsOnLeave() {
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(today);

    return FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> studentsOnLeave = [];

      for (var studentDoc in querySnapshot.docs) {
        DocumentSnapshot leaveSnapshot = await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(studentDoc.id)
            .collection('newLeaveDetails')
            .doc(formattedDate)
            .get();

        if (leaveSnapshot.exists) {
          studentsOnLeave.add({
            'roomNumber': studentDoc['roomNumber'],
            'rollNumber': studentDoc.id,
            'meals': (leaveSnapshot.data()
                    as Map<String, dynamic>)['onLeaveMeals'] ??
                [],
          });
        }
      }
      return studentsOnLeave;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students on Leave',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(DateFormat('dd-MM-yyyy').format(DateTime.now())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Room Number / Roll Number',
                labelStyle: Theme.of(context).textTheme.bodySmall,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchStudentsOnLeave(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students on leave'));
                }

                List<Map<String, dynamic>> studentsOnLeave = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  studentsOnLeave = studentsOnLeave
                      .where((student) =>
                          student['roomNumber'].contains(_searchQuery) ||
                          student['rollNumber'].contains(_searchQuery))
                      .toList();
                }

                if (studentsOnLeave.isEmpty) {
                  return const Center(child: Text('No students on leave'));
                }

                return ListView.builder(
                  itemCount: studentsOnLeave.length,
                  itemBuilder: (context, index) {
                    final student = studentsOnLeave[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          'Room Number: ${student['roomNumber']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Roll Number: ${student['rollNumber']}',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            Text('Meals: ${student['meals'].join(', ')}',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    );
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
