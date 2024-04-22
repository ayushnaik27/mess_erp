import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/clerk/all_tender_screen.dart';
import 'package:mess_erp/clerk/open_tender_screen.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';

class ClerkDashboardScreen extends StatefulWidget {
  static const routeName = '/clerkDashboard';
  const ClerkDashboardScreen({super.key});

  @override
  State<ClerkDashboardScreen> createState() => _ClerkDashboardScreenState();
}

class _ClerkDashboardScreenState extends State<ClerkDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clerk Dashboard'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/monthlyReportScreen');
                },
                child: const Text('Generate Monthly Report'),
              ),
              ElevatedButton(
                onPressed: () => showAdaptiveDialog(
                  context: context,
                  builder: (context) {
                    return AddStudentDialog();
                  },
                ),
                child: const Text('Add Student'),
              ),
              ElevatedButton(
                onPressed: () => showAdaptiveDialog(
                  context: context,
                  builder: (context) {
                    return ImposeFineDialog();
                  },
                ),
                child: const Text('Impose Fine on Student'),
              ),
              ElevatedButton(
                onPressed: () => showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AddManagerDialog();
                    }),
                child: const Text('Add Manager'),
              ),
              ElevatedButton(
                onPressed: () => showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AddMuneemDialog();
                    }),
                child: const Text('Add Muneem'),
              ),
              ElevatedButton(
                onPressed: () => showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AddCommitteeDialog();
                    }),
                child: const Text('Add Committee Member'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AssignedGrievancesScreen(userType: 'clerk'),
                      ));
                },
                child: const Text('View Assigned Grievances'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OpenTenderScreen()));
                },
                child: const Text('Open Tender'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllTendersScreen()));
                },
                child: const Text('View All Tenders'),
              ),
            ],
          ),
        ),
      ),
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
      title: const Text('Add Student'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: rollNumberController,
            decoration: const InputDecoration(
              labelText: 'Roll Number',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(rollNumberController.text)
              .set({
                'name': nameController.text,
                'rollNumber': rollNumberController.text,
                'role': 'student',
                'password': '12345678'
              })
              .then((value) => Navigator.pop(context))
              .catchError((error) => print('Failed to add student: $error')),
          child: const Text('Add'),
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
      title: const Text('Impose Fine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: rollNumberController,
            decoration: const InputDecoration(
              labelText: 'Roll Number',
            ),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
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
          child: const Text('Add'),
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
      title: const Text('Add Manager'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('manager')
              .doc(emailController.text)
              .set({
                'name': nameController.text,
                'email': emailController.text,
                'role': 'manager',
                'password': '12345678'
              })
              .then((value) => Navigator.pop(context))
              .catchError((error) => print('Failed to add manager: $error')),
          child: const Text('Add'),
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
      title: const Text('Add Committee Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('committee')
              .doc(emailController.text)
              .set({
                'name': nameController.text,
                'email': emailController.text,
                'role': 'committee',
                'password': '12345678'
              })
              .then((value) => Navigator.pop(context))
              .catchError(
                  (error) => print('Failed to add committee member: $error')),
          child: const Text('Add'),
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
      title: const Text('Add Muneem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('muneem')
              .doc(emailController.text)
              .set({
                'name': nameController.text,
                'email': emailController.text,
                'role': 'muneem',
                'password': '12345678'
              })
              .then((value) => Navigator.pop(context))
              .catchError((error) => print('Failed to add muneem: $error')),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
