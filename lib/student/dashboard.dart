import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/helpers/mess_menu_helper.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/mess_bill_screen.dart';
import 'package:mess_erp/student/qr_scanner_screen.dart';
import 'package:mess_erp/student/request_extra_items_screen.dart';
import 'package:mess_erp/student/track_leaves_screen.dart';
import 'package:provider/provider.dart';

import '../providers/announcement_provider.dart';
import '../providers/hash_helper.dart';

class StudentDashboardScreen extends StatefulWidget {
  static const routeName = '/studentDashboard';
  final String? rollNumber;
  const StudentDashboardScreen({super.key, this.rollNumber});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  List<MessBill> messBills = [];
  bool isMealLive = false;
  @override
  void initState() {
    super.initState();
    AnnouncementServices().deleteOldAnnouncements();
    FirebaseFirestore.instance
        .collection('meal')
        .doc('meal')
        .snapshots()
        .listen((event) {
      setState(() {
        isMealLive = event.data()?['status'] == 'started';
      });
    });
  }

  void changePassword(String rollNumber, String newPassword) async {
    String hashedPassword = HashHelper.encode(newPassword);
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .doc(rollNumber)
        .update({
      'password': hashedPassword,
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  final AnnouncementServices announcementService = AnnouncementServices();
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
                    child: Text(user.name[0].toUpperCase()),
                    // child: Text("H"),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        capitalize(user.name),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
              title: const Text('Track Leaves'),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return TrackLeavesScreen(studentRollNumber: user.username);
                }));
              },
            ),
            ListTile(
              title: const Text('Track Complaints'),
              onTap: () {
                Navigator.of(context).pushNamed('/trackComplaints');
              },
            ),
            ListTile(
              title: const Text('File Grievance'),
              onTap: () {
                Navigator.of(context).pushNamed('/fileGrievance');
              },
            ),
            ListTile(
              title: const Text('View Mess Menu'),
              onTap: () {
                MessMenuHelper.viewMessMenu();
              },
            ),
            ListTile(
              title: const Text('View Mess Bill'),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MessBillScreen(studentId: user.username);
                }));
              },
            ),
            ListTile(
              title: const Text('Apply for Leave'),
              onTap: () {
                Navigator.of(context).pushNamed(ApplyLeaveScreen.routeName,
                    arguments: user.username);
              },
            ),
            ListTile(
              title: const Text('Request Extra Items'),
              onTap: () {
                Navigator.of(context).pushNamed(
                    RequestExtraItemsScreen.routeName,
                    arguments: user.username);
              },
            ),
            ListTile(
              title: const Text('Mess Bill'),
              onTap: () {
                Navigator.of(context).pushNamed(MessBillScreen.routeName,
                    arguments: user.username);
              },
            ),
            ListTile(
              title: const Text('Change Password'),
              onTap: () {
                showAdaptiveDialog(
                  context: context,
                  builder: (context) {
                    return ChangePasswordDialog(
                      rollNumber: user.username,
                      changePassword: changePassword,
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {},
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text('Student Dashboard'),
        actions: [
          isMealLive
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return QRScannerScreen(rollNumber: user.username);
                    }));
                  },
                  icon: const Icon(Icons.qr_code_scanner))
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                  child: Text(
                    'Welcome ${capitalize(Provider.of<UserProvider>(context).user.name)}',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(height: 8.0),
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

                      if (announcements.isEmpty) {
                        return const Center(
                            child: Text('No announcements available'));
                      }

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

                              print(announcements[index].file?.path);
                            },
                          );
                        },
                      );
                    }
                  },
                )),
              ),
              const SizedBox(height: 16.0),
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
                        Navigator.of(context).pushNamed(
                            RequestExtraItemsScreen.routeName,
                            arguments: user.username);
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.food_bank),
                            SizedBox(height: 16.0),
                            Text('Request Extra Items'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            ApplyLeaveScreen.routeName,
                            arguments: user.username);
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(height: 16.0),
                            Text('Apply for Leave'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return MessBillScreen(studentId: user.username);
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pageview),
                            SizedBox(height: 16.0),
                            Text('View Mess Bill'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        MessMenuHelper.viewMessMenu();
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.food_bank),
                            SizedBox(height: 16.0),
                            Text('View Mess Menu'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/fileGrievance');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error),
                            SizedBox(height: 16.0),
                            Text('File Grievance'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/trackComplaints');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.track_changes_outlined),
                            SizedBox(height: 16.0),
                            Text('Track Complaints'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return TrackLeavesScreen(
                              studentRollNumber: user.username);
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.food_bank),
                            SizedBox(height: 16.0),
                            Text('Track Leaves'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // TextButton(
              //     onPressed: () {
              //       print(user.name);
              //       Navigator.of(context).pushNamed(
              //           RequestExtraItemsScreen.routeName,
              //           arguments: user.username);
              //       // MaterialPageRoute(builder: (context) {
              //       //   return RequestExtraItemsScreen();
              //       // });
              //     },
              //     child: const Text('Request Extra Items')),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed(ApplyLeaveScreen.routeName,
              //         arguments: user.username);
              //   },
              //   child: const Text('Apply for Leave'),
              // ),
              // TextButton(
              //     onPressed: () {
              //       print(user.username);
              //       Navigator.of(context)
              //           .push(MaterialPageRoute(builder: (context) {
              //         return MessBillScreen(studentId: user.username);
              //       }));
              //     },
              //     child: const Text('View Mess Bill')),
              // TextButton(
              //     onPressed: () {
              //       MessMenuHelper.viewMessMenu();
              //     },
              //     child: const Text('View Mess Menu')),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/fileGrievance');
              //   },
              //   child: const Text('File Grievance'),
              // ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/trackComplaints');
              //   },
              //   child: const Text('Track Complaints'),
              // ),
              // isMealLive
              //     ? TextButton(
              //         onPressed: () {
              //           Navigator.of(context)
              //               .push(MaterialPageRoute(builder: (context) {
              //             return QRScannerScreen(rollNumber: user.username);
              //           }));
              //         },
              //         child: const Text('Scan QR Code'),
              //       )
              //     : const SizedBox(),
              // TextButton(
              //   child: const Text("Track Leaves"),
              //   onPressed: () {
              //     Navigator.of(context)
              //         .push(MaterialPageRoute(builder: (context) {
              //       return TrackLeavesScreen(studentRollNumber: user.username);
              //     }));
              //   },
              // )
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
