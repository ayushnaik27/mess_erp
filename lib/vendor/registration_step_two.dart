// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:mess_erp/vendor/vendor_login_screen.dart';

// import '../providers/vendor_provider.dart';

// class VendorSetPassword extends StatefulWidget {
//   final Vendor vendor;

//   const VendorSetPassword({super.key, required this.vendor});
//   @override
//   _VendorSetPasswordState createState() => _VendorSetPasswordState();
// }

// class _VendorSetPasswordState extends State<VendorSetPassword> {
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Password'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 80.0),
//               const Text(
//                 'Please set a password',
//                 style: TextStyle(
//                   fontSize: 40.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               const SizedBox(height: 10.0),
//               TextField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                     labelText: 'Password', border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 16.0),
//               TextField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                     labelText: 'Confirm Password',
//                     border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 16.0),
//               const SizedBox(height: 30.0),
//               ElevatedButton(
//                 onPressed: () {
//                   if (passwordController.text ==
//                       confirmPasswordController.text) {
//                     widget.vendor.password = passwordController.text;
//                     FirebaseFirestore.instance
//                         .collection('vendors')
//                         .doc(widget.vendor.emailId)
//                         .set(widget.vendor.toMap(), SetOptions(merge: true));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text(
//                             'Registration successful! Please login to continue'),
//                       ),
//                     );
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Passwords do not match'),
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text('Set Password'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
