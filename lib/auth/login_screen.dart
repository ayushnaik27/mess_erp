import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/hash_helper.dart';
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
        // backgroundColor: const Color.fromRGBO(254, 214, 91, 1),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: adminLogin ? const Text('Admin Login') : const Text('Login'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VendorLoginScreen();
                }));
              },
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0))),
              child: const Text('Vendor Login')),
          adminLogin
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      adminLogin = false;
                    });
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                  child: const Text('Student Login'))
              : TextButton(
                  onPressed: () {
                    setState(() {
                      adminLogin = true;
                    });
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                  child: const Text('Admin Login')),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          // Image.asset(
          //   'assets/images/icon_background.png',
          //   fit: BoxFit.cover,
          //   height: double.infinity,
          //   width: double.infinity,
          //   alignment: Alignment.center,
          // ),
          Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/icon_foreground.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/images/nitj.png',
                      height: 100.0, width: 100.0),
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
                        dropdownColor: Theme.of(context).colorScheme.primary,
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
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                        labelStyle: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .fontSize,
                            color: Colors.black),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Username',
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16.0),
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
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .fontSize,
                            color: Colors.black),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'Password',
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32.0),
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
                                HashHelper.encode(passwordController.text)) {
                              print('password is correct');
                              Provider.of<UserProvider>(context, listen: false)
                                  .fetchUserDetails(usernameController.text,
                                      admin: true, role: role);
                              Provider.of<VendorProvider>(context,
                                      listen: false)
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
                                      content:
                                          const Text('Invalid Credentials'),
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
                                HashHelper.encode(passwordController.text)) {
                              print('password is correct');
                              Provider.of<UserProvider>(context, listen: false)
                                  .fetchUserDetails(usernameController.text,
                                      role: 'student');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDashboardScreen(
                                    rollNumber: usernameController.text,
                                  ),
                                ),
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
                                      content:
                                          const Text('Invalid Credentials'),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shadowColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('Login'),
                  ),
                  TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text('Please contact Clerk to reset password'),
                          duration: Duration(seconds: 2),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.tertiary,
                        shadowColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Text('Forgot Password?'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
