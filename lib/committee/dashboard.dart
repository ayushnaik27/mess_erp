import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/committee/bill_screen.dart';
import 'package:mess_erp/features/student/models/announcement_model.dart';
import 'package:mess_erp/features/student/services/announcement_service.dart';
import 'package:provider/provider.dart';

import '../helpers/mess_menu_helper.dart';
import '../providers/hash_helper.dart';
import '../providers/user_provider.dart';
import '../widgets/change_password_dialog.dart';

class CommitteeDashboardScreen extends StatefulWidget {
  static const routeName = '/committeeDashboard';
  const CommitteeDashboardScreen({super.key});

  @override
  State<CommitteeDashboardScreen> createState() =>
      _CommitteeDashboardScreenState();
}

class _CommitteeDashboardScreenState extends State<CommitteeDashboardScreen> {
  final AnnouncementService announcementService = AnnouncementService();
  @override
  void initState() {
    super.initState();
    AnnouncementService().deleteOldAnnouncements();
  }

  void changePassword(String newPassword) async {
    String hashedPassword = HashHelper.encode(newPassword);
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('committee')
        .doc('committee@gmail.com')
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
                    child: const Text('M'),
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
                'Add Announcement',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/addAnnouncement');
              },
            ),
            ListTile(
              title: Text(
                'Manage Extra Items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/extraItems');
              },
            ),
            ListTile(
              title: Text(
                'View Bills',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(BillsScreen.routeName);
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
                        changePassword: changePassword,
                      );
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
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Committee Dashboard'),
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Announcements',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                            title: Text(
                              announcements[index].title,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            subtitle: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    announcements[index].description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').add_jm().format(
                                        announcements[index]
                                            .timestamp!
                                            .toDate()),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
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
                                  : AnnouncementService().openAnnouncement(
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
                        MessMenuHelper.viewMessMenu();
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Show Mess Menu',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        MessMenuHelper.pickDocsFile().then(
                          (uploaded) {
                            if (uploaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mess Menu Uploaded'),
                                ),
                              );
                            } else {
                              showAdaptiveDialog(
                                  context: context,
                                  builder: (
                                    context,
                                  ) {
                                    return const AlertDialog(
                                      title: Text('Error'),
                                      content:
                                          Text('Error Uploading Mess Menu'),
                                    );
                                  });
                            }
                          },
                        );
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file),
                            const SizedBox(height: 16.0),
                            Text(
                              'Upload Mess Menu',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(BillsScreen.routeName);
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt),
                            const SizedBox(height: 16.0),
                            Text(
                              'Show Bills',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/addAnnouncement');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.announcement),
                            const SizedBox(height: 16.0),
                            Text(
                              'Add Announcement',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/extraItems');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_shopping_cart),
                            const SizedBox(height: 16.0),
                            Text(
                              'Extra Items',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/previousVouchers');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long),
                            const SizedBox(height: 16.0),
                            Text(
                              'Previous Vouchers',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const AssignedGrievancesScreen(
                              userType: 'committee');
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment),
                            const SizedBox(height: 16.0),
                            Text(
                              'View Assigned Grievances',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/viewAllGrievances');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_turned_in),
                            const SizedBox(height: 16.0),
                            Text(
                              'View All Grievances',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     MessMenuHelper.viewMessMenu();
              //   },
              //   child: const Text('Show Mess Menu'),
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(
              //   onPressed: () {
              //     MessMenuHelper.pickDocsFile().then(
              //       (uploaded) {
              //         if (uploaded) {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(
              //               content: Text('Mess Menu Uploaded'),
              //             ),
              //           );
              //         } else {
              //           showAdaptiveDialog(
              //               context: context,
              //               builder: (
              //                 context,
              //               ) {
              //                 return const AlertDialog(
              //                   title: Text('Error'),
              //                   content: Text('Error Uploading Mess Menu'),
              //                 );
              //               });
              //         }
              //       },
              //     );
              //   },
              //   child: const Text('Upload Mess Menu'),
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed(BillsScreen.routeName);
              //   },
              //   child: const Text('Show Bills'),
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/addAnnouncement');
              //   },
              //   child: const Text('Add Announcement'),
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/extraItems');
              //   },
              //   child: const Text('Extra Items'),
              // ),
              // const SizedBox(height: 8.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/previousVouchers');
              //   },
              //   child: const Text('Previous Vouchers'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) {
              //       return const AssignedGrievancesScreen(
              //           userType: 'committee');
              //     }));
              //   },
              //   child: const Text('View Assigned Grievances'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/viewAllGrievances');
              //   },
              //   child: const Text('View All Grievances'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// class SetUrlDialog extends StatelessWidget {
//   final TextEditingController _urlController = TextEditingController();
//   SetUrlDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Set Mess Menu Url'),
//       content: TextField(
//         controller: _urlController,
//         decoration: const InputDecoration(
//           labelText: 'Url',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             MessMenuHelper.setGoogleDocsUrl(_urlController.text);
//             Navigator.of(context).pop();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
