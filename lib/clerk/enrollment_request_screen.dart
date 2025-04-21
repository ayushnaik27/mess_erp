import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestScreen extends StatefulWidget {
  const EnrollmentRequestScreen({super.key});

  @override
  State<EnrollmentRequestScreen> createState() =>
      _EnrollmentRequestScreenState();
}

class _EnrollmentRequestScreenState extends State<EnrollmentRequestScreen> {
  Future<Map<String, dynamic>> _getEnrollmentRequests() async {
    Map<String, dynamic> enrollmentRequests = {};
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('enrollments').get();
    for (var element in snapshot.docs) {
      enrollmentRequests[element.id] = element.data();
    }
    return enrollmentRequests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enrollment Request')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getEnrollmentRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No enrollment requests found.'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    String key = snapshot.data!.keys.elementAt(index);
                    String name = snapshot.data![key]['name'] ?? 'Unknown';
                    String rollNumber =
                        snapshot.data![key]['rollNumber'] ?? 'Unknown';
                    String password =
                        snapshot.data![key]['password'] ?? 'Unknown';

                    return Card(
                      child: ListTile(
                        title: Text(key),
                        subtitle: Text(name),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Remove student from the enrollment collection
                                    FirebaseFirestore.instance
                                        .collection('enrollments')
                                        .doc(key)
                                        .delete();
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    // Add student to the student collection
                                    FirebaseFirestore.instance
                                        .collection('loginCredentials')
                                        .doc('roles')
                                        .collection('student')
                                        .doc(rollNumber)
                                        .set({
                                      'name': name,
                                      'rollNumber': rollNumber,
                                      'role': 'student',
                                      'password': password,
                                    }).then(
                                      (_) {
                                        FirebaseFirestore.instance
                                            .collection('enrollments')
                                            .doc(key)
                                            .delete();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text('Student added'),
                                          backgroundColor: Colors.green,
                                        ));
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                              ]),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
