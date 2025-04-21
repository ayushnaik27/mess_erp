import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class StudentRegisterScreen extends StatelessWidget {
  const StudentRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController rollNumberController = TextEditingController();
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

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // Check if roll number already exists in login credentials
                    DocumentSnapshot documentSnapshot = await FirebaseFirestore
                        .instance
                        .collection('loginCredentials')
                        .doc('roles')
                        .collection('student')
                        .doc(rollNumberController.text)
                        .get();

                    if (documentSnapshot.exists) {
                      returnMessage = "Roll number already exists";
                    } else {
                      // Check if roll number is pending verification
                      DocumentSnapshot enrollmentSnapshot =
                          await FirebaseFirestore.instance
                              .collection('enrollments')
                              .doc(rollNumberController.text)
                              .get();

                      if (enrollmentSnapshot.exists) {
                        returnMessage = "Verification Pending";
                      } else {
                        // All checks passed, register the student
                        String password =
                            HashHelper.encode(passwordController.text);

                        await FirebaseFirestore.instance
                            .collection('enrollments')
                            .doc(rollNumberController.text)
                            .set({
                          'name': nameController.text,
                          'password': password,
                          'rollNumber': rollNumberController.text,
                          'email': emailController.text
                        });

                        returnMessage = "Registered Successfully";
                      }
                    }
                  } catch (e) {
                    // Handle Firestore errors
                    print("Firestore error: $e");
                    returnMessage =
                        "Registration failed. Please check your connection and try again.";
                  } finally {
                    // Close loading dialog
                    Navigator.of(context).pop();
                  }

                  // Show appropriate message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(returnMessage),
                    backgroundColor: returnMessage == "Registered Successfully"
                        ? Colors.green
                        : Colors.red,
                  ));

                  if (returnMessage == "Registered Successfully") {
                    Navigator.of(context).pop();
                  }
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
