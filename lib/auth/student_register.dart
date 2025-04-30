import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class StudentRegisterScreen extends StatelessWidget {
  const StudentRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController rollNumberController = TextEditingController();
    TextEditingController roomNumberController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Student Register'),
              TextField(
                controller: rollNumberController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Roll Number',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomNumberController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Room Number',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: emailController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Email',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Name',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                style: Theme.of(context).textTheme.bodyMedium,
                obscureText: true,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Password',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    labelStyle: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  // Register the student
                  String returnMessage = "";

                  if (rollNumberController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty ||
                      roomNumberController.text.isEmpty ||
                      emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please fill all the fields'),
                    ));
                    return;
                  }

                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Passwords do not match'),
                    ));
                    return;
                  }

                  DocumentSnapshot documentSnapsgot = await FirebaseFirestore
                      .instance
                      .collection('loginCredentials')
                      .doc('roles')
                      .collection('student')
                      .doc(rollNumberController.text)
                      .get();
                  if (documentSnapsgot.exists) {
                    returnMessage = "Roll number already exists";
                  } else {
                    DocumentSnapshot documentSnapshotEnrollments =
                        await FirebaseFirestore.instance
                            .collection('enrollments')
                            .doc(rollNumberController.text)
                            .get();
                    if (documentSnapshotEnrollments.exists) {
                      returnMessage = "Verification Pending";
                    }
                  }

                  if (returnMessage.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(returnMessage),
                    ));
                    Navigator.of(context).pop();
                    return;
                  }

                  String password = HashHelper.encode(passwordController.text);

                  FirebaseFirestore.instance
                      .collection('enrollments')
                      .doc(rollNumberController.text)
                      .set({
                    'name': nameController.text,
                    'password': password,
                    'rollNumber': rollNumberController.text,
                    'roomNumber': roomNumberController.text,
                    'email': emailController.text
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Registered Successfully'),
                    backgroundColor: Colors.green,
                  ));
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shadowColor: Theme.of(context).colorScheme.secondary,
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
