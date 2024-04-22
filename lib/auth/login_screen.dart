import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/vendor_provider.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../student/dashboard.dart';
import '../vendor/vendor_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool adminLogin = false;
  String role = 'Select Role';
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: adminLogin ? const Text('Admin Login') : const Text('Login'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VendorLoginScreen();
                }));
              },
              child: const Text('Vendor Login')),
          adminLogin
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      adminLogin = false;
                    });
                  },
                  child: const Text('Student Login'))
              : TextButton(
                  onPressed: () {
                    setState(() {
                      adminLogin = true;
                    });
                  },
                  child: const Text('Admin Login')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to NITJ Mess',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              if (adminLogin)
                DropdownButton(
                    hint: Text(role),
                    elevation: 0,
                    autofocus: false,
                    items: const [
                      DropdownMenuItem(
                        value: 'clerk',
                        child: Text('Clerk'),
                      ),
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text('Manager'),
                      ),
                      DropdownMenuItem(
                        value: 'muneem',
                        child: Text('Muneem'),
                      ),
                      DropdownMenuItem(
                        value: 'committee',
                        child: Text('Committee'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        role = value.toString();
                      });
                    }),
              if (!adminLogin) const SizedBox(height: 47.0),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (adminLogin) {
                    FirebaseFirestore.instance
                        .collection('loginCredentials')
                        .doc('roles')
                        .collection(role)
                        .doc(usernameController.text)
                        .get()
                        .then((value) {
                      if (value.exists) {
                        print('value exists ${value.data()}');
                        if (value.data()!['password'] ==
                            passwordController.text) {
                          print('password is correct');
                          Provider.of<UserProvider>(context, listen: false)
                              .fetchUserDetails(usernameController.text,
                                  admin: true, role: role);
                          Provider.of<VendorProvider>(context, listen: false)
                              .fetchAndSetVendors();
                          Navigator.pushNamed(context, '/${role}Dashboard',
                              arguments: {
                                'email': usernameController.text,
                              });
                        } else {
                          print('password is incorrect');
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Invalid Credentials'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                        }
                      } else {
                        print('value does not exist1');
                      }
                    });
                  }
                  // Implement authentication logic
                  else {
                    FirebaseFirestore.instance
                        .collection('loginCredentials')
                        .doc('roles')
                        .collection('student')
                        .doc(usernameController.text)
                        .get()
                        .then((value) {
                      if (value.exists) {
                        print('value exists ${value.data()}');
                        if (value.data()!['password'] ==
                            passwordController.text) {
                          print('password is correct');
                          Provider.of<UserProvider>(context, listen: false)
                              .fetchUserDetails(usernameController.text,
                                  role: 'student');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentDashboardScreen(
                                      rollNumber: usernameController.text,
                                    )),
                          );
                          passwordController.clear();
                          usernameController.clear();
                        } else {
                          print('password is incorrect');
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Invalid Credentials'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                        }
                      } else {
                        print('value does not exist');
                      }
                    });
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please contact Clerk to reset password'),
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: const Text('Forgot Password?'))
            ],
          ),
        ),
      ),
    );
  }
}
