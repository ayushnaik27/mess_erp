import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/helpers/mess_menu_helper.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/mess_bill_screen.dart';
import 'package:mess_erp/student/request_extra_items_screen.dart';
import 'package:provider/provider.dart';

import '../providers/announcement_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const routeName = '/studentDashboard';
  final String? rollNumber;
  const StudentDashboardScreen({super.key, this.rollNumber});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  List<MessBill> messBills = [];
  @override
  void initState() {
    super.initState();
    AnnouncementServices().deleteOldAnnouncements();
  }

  void changePassword(String rollNumber, String newPassword) async {
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .doc(rollNumber)
        .update({
      'password': newPassword,
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  final AnnouncementServices announcementService = AnnouncementServices();
  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          TextButton(
            onPressed: () => showAdaptiveDialog(
              context: context,
              builder: (context) {
                return ChangePasswordDialog(
                  rollNumber: widget.rollNumber,
                  changePassword: changePassword,
                );
              },
            ),
            child: const Text(
              'change password',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder(
                  future: Future.delayed(const Duration(seconds: 1)),
                  builder: (context, snapshot) => Text(
                    'Welcome ${capitalize(Provider.of<UserProvider>(context).user.name)}',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Announcements'),
              ),
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Scrollbar(
                    child: StreamBuilder<List<Announcement>>(
                  stream: announcementService.getAnnouncements(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Announcement> announcements = snapshot.data ?? [];

                      

                      // Display announcements
                      return ListView.builder(
                        itemCount: announcements.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(announcements[index].title),
                            subtitle: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(announcements[index].description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').add_jm().format(
                                        announcements[index]
                                            .timestamp!
                                            .toDate()),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                                const Divider()
                              ],
                            ),
                            onTap: () {
                              bool openBill = false;
                              if (announcements[index].title == 'Mess Bill') {
                                openBill = true;
                              }
                              print(openBill);
                              announcements[index].file == null
                                  ? null
                                  : AnnouncementServices().openAnnouncement(
                                      announcements[index].file!.path,
                                      openBill: openBill);

                              print(announcements[index].file!.path);
                            },
                          );
                        },
                      );
                    }
                  },
                )),
              ),
              TextButton(
                  onPressed: () {
                    print(user.name);
                    Navigator.of(context).pushNamed(
                        RequestExtraItemsScreen.routeName,
                        arguments: user.username);
                    // MaterialPageRoute(builder: (context) {
                    //   return RequestExtraItemsScreen();
                    // });
                  },
                  child: const Text('Request Extra Items')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ApplyLeaveScreen.routeName,
                      arguments: user.username);
                },
                child: const Text('Apply for Leave'),
              ),
              TextButton(
                  onPressed: () {
                    print(user.username);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MessBillScreen(studentId: user.username);
                    }));
                  },
                  child: const Text('View Mess Bill')),
              TextButton(
                  onPressed: () {
                    MessMenuHelper.viewMessMenu();
                  },
                  child: const Text('View Mess Menu')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/fileGrievance');
                },
                child: const Text('File Grievance'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/trackComplaints');
                },
                child: const Text('Track Complaints'),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: messBills.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Month: ${messBills[index]}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Diets: ${messBills[index].totalDiets}'),
                          Text('Total Extra: ${messBills[index].totalExtra}'),
                          Text('Fine: ${messBills[index].fine}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatelessWidget {
  final String? rollNumber;
  final Function(String, String) changePassword;
  const ChangePasswordDialog(
      {Key? key, this.rollNumber, required this.changePassword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newPasswordController = TextEditingController();
    return AlertDialog(
      title: const Text('Change Password'),
      content: TextField(
        controller: newPasswordController,
        decoration: const InputDecoration(
          labelText: 'New Password',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            changePassword(rollNumber!, newPasswordController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Change'),
        ),
      ],
    );
  }
}
