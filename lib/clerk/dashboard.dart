import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/clerk/all_tender_screen.dart';
import 'package:mess_erp/clerk/enrollment_request_screen.dart';
import 'package:mess_erp/clerk/open_tender_screen.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/providers/hash_helper.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/widgets/change_password_dialog.dart';
import 'package:provider/provider.dart';

class ClerkDashboardScreen extends StatefulWidget {
  static const routeName = '/clerkDashboard';
  const ClerkDashboardScreen({super.key});

  @override
  State<ClerkDashboardScreen> createState() => _ClerkDashboardScreenState();
}

class _ClerkDashboardScreenState extends State<ClerkDashboardScreen> {
  void changePassword(String newPassword) async {
    String hashedPassword = HashHelper.encode(newPassword);
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('clerk')
        .doc('admin')
        .update({
      'password': hashedPassword,
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      radius: 30,
                      child: const Text("A")
                      // child: Text("H"),
                      ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //   capitalize(user.name),
                      //   style: Theme.of(context).textTheme.bodyLarge,
                      // ),
                      Text(
                        user.username,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Generate Monthly Report',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/monthlyReportScreen');
              },
            ),
            ListTile(
              title: Text(
                'Open Tender',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpenTenderScreen()));
              },
            ),
            ListTile(
              title: Text(
                'View All Tenders',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllTendersScreen()));
              },
            ),
            ListTile(
              title: Text(
                'Change Password',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return ChangePasswordDialog(
                          changePassword: changePassword);
                    });
              },
            ),
            ListTile(
                title: Text(
                  'Log Out',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Clerk Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView(
                  physics: const ScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/monthlyReportScreen');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Generate Monthly Report',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AddStudentDialog();
                        },
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(height: 16.0),
                            Text(
                              'Add Student',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AddVendorDialog();
                        },
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(height: 16.0),
                            Text(
                              'Add Vendor',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return ImposeFineDialog();
                        },
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.money),
                            const SizedBox(height: 16.0),
                            Text(
                              'Impose Fine on Student',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () => showAdaptiveDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return AddManagerDialog();
                    //     },
                    //   ),
                    //   child: Card(
                    //     color: Theme.of(context).colorScheme.primary,
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(Icons.person_add),
                    //         const SizedBox(height: 16.0),
                    //         Text(
                    //           'Add Manager',
                    //           textAlign: TextAlign.center,
                    //           style: Theme.of(context).textTheme.displayMedium,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AddMuneemDialog();
                        },
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(height: 16.0),
                            Text(
                              'Add Muneem',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) {
                          return AddCommitteeDialog();
                        },
                      ),
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(height: 16.0),
                            Text(
                              'Add Committee Member',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () => showAdaptiveDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return AddVendorDialog();
                    //     },
                    //   ),
                    //   child: Card(
                    //     color: Theme.of(context).colorScheme.primary,
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(Icons.person_add),
                    //         const SizedBox(height: 16.0),
                    //         Text(
                    //           'Add Vendor',
                    //           style: Theme.of(context).textTheme.displayMedium,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AssignedGrievancesScreen(
                                      userType: 'clerk'),
                            ));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add),
                            const SizedBox(height: 16.0),
                            Text(
                              'View Assigned Grievances',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OpenTenderScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.open_in_new),
                            const SizedBox(height: 16.0),
                            Text(
                              'Open Tender',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllTendersScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.remove_red_eye),
                            const SizedBox(height: 16.0),
                            Text(
                              'View All Tenders',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EnrollmentRequestScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded),
                            const SizedBox(height: 16.0),
                            Text(
                              'Enrollment   Requests',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class AddVendorDialog extends StatelessWidget {
//   AddVendorDialog({super.key});

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(
//         'Add Vendor',
//         style: Theme.of(context).textTheme.titleMedium,
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: InputDecoration(
//                 labelText: 'Name',
//                 labelStyle: Theme.of(context).textTheme.bodyMedium),
//           ),
//           TextField(
//             controller: emailController,
//             decoration: InputDecoration(
//                 labelText: 'Email',
//                 labelStyle: Theme.of(context).textTheme.bodyMedium),
//           ),
//         ],
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context),
//           style:
//               ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
//           child: Text('Cancel',
//               style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             String password = HashHelper.encode('12345678');
//             FirebaseFirestore.instance
//                 .collection('loginCredentials')
//                 .doc('roles')
//                 .collection('vendor')
//                 .doc(emailController.text)
//                 .set({
//                   'name': nameController.text,
//                   'email': emailController.text,
//                   'role': 'vendor',
//                   'password': password
//                 })
//                 .then((value) => Navigator.pop(context))
//                 .catchError((error) => print('Failed to add vendor: $error'));
//           },
//           style:
//               ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
//           child: Text('Add',
//               style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
//         ),
//       ],
//     );
//   }
// }

class AddVendorDialog extends StatelessWidget {
  AddVendorDialog({super.key});

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Vendor',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('vendorList')
                .doc(nameController.text)
                .set({
                  'name': nameController.text,
                })
                .then((value) => Navigator.pop(context))
                .catchError((error) => print('Failed to add vendor: $error'));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text(
            'Add',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        )
      ],
    );
  }
}

class AddStudentDialog extends StatelessWidget {
  AddStudentDialog({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Student',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          TextField(
            controller: rollNumberController,
            decoration: InputDecoration(
                labelText: 'Roll Number',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            String password = HashHelper.encode('12345678');
            FirebaseFirestore.instance
                .collection('loginCredentials')
                .doc('roles')
                .collection('student')
                .doc(rollNumberController.text)
                .set({
                  'name': nameController.text,
                  'rollNumber': rollNumberController.text,
                  'role': 'student',
                  'password': password
                })
                .then((value) => Navigator.pop(context))
                .catchError((error) => print('Failed to add student: $error'));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Add',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
      ],
    );
  }
}

class ImposeFineDialog extends StatelessWidget {
  ImposeFineDialog({super.key});

  final TextEditingController amountController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Impose Fine',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: rollNumberController,
            decoration: InputDecoration(
              labelText: 'Roll Number',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(rollNumberController.text)
              .collection('fineDetails')
              .doc()
              .set({
                'amount':
                    FieldValue.increment(double.parse(amountController.text)),
                'date': DateTime.now().toString(),
              }, SetOptions(merge: true))
              .then((value) => Navigator.pop(context))
              .catchError((error) => print('Failed to add student: $error')),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Add',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
      ],
    );
  }
}

class AddManagerDialog extends StatelessWidget {
  AddManagerDialog({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Add Manager', style: Theme.of(context).textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            String password = HashHelper.encode('12345678');
            FirebaseFirestore.instance
                .collection('loginCredentials')
                .doc('roles')
                .collection('manager')
                .doc(emailController.text)
                .set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': 'manager',
                  'password': password
                })
                .then((value) => Navigator.pop(context))
                .catchError((error) => print('Failed to add manager: $error'));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Add',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
      ],
    );
  }
}

class AddCommitteeDialog extends StatelessWidget {
  AddCommitteeDialog({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Committee Member',
          style: Theme.of(context).textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            String password = HashHelper.encode('12345678');
            FirebaseFirestore.instance
                .collection('loginCredentials')
                .doc('roles')
                .collection('committee')
                .doc(emailController.text)
                .set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': 'committee',
                  'password': password
                })
                .then((value) => Navigator.pop(context))
                .catchError(
                    (error) => print('Failed to add committee member: $error'));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Add',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
      ],
    );
  }
}

class AddMuneemDialog extends StatelessWidget {
  AddMuneemDialog({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Muneem',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            String password = HashHelper.encode('12345678');
            FirebaseFirestore.instance
                .collection('loginCredentials')
                .doc('roles')
                .collection('muneem')
                .doc(emailController.text)
                .set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': 'muneem',
                  'password': password
                })
                .then((value) => Navigator.pop(context))
                .catchError((error) => print('Failed to add muneem: $error'));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Text('Add',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
      ],
    );
  }
}
