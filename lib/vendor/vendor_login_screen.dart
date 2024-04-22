import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/vendor_provider.dart';
import 'package:mess_erp/vendor/dashboard.dart';
import 'package:mess_erp/vendor/registration_screen.dart';
import 'package:provider/provider.dart';

class VendorLoginScreen extends StatefulWidget {
  @override
  _VendorLoginScreenState createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80.0),
              const Text(
                'Welcome to NITJ Mess',
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  // Implement login functionality
                  FirebaseFirestore.instance.collection('vendors').doc(usernameController.text).get().then((value) async {
                    if (value.exists) {
                      if (value.data()!['password'] == passwordController.text) {

                        await Provider.of<VendorProvider>(context, listen: false).setCurrentVendor(usernameController.text);

                        // Navigate to dashboard
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return VendorDashboardScreen();
                        }));
                        print('Username : ${usernameController.text}');
                        usernameController.clear();
                        passwordController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Invalid Password'),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('User not found'),
                      ));
                    }
                  });
                },
                child: const Text('Login'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return VendorRegisterScreen();
                      }));
                    },
                    child: const Text('Register Here'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
