import 'package:flutter/material.dart';
import 'package:mess_erp/committee/bill_screen.dart';
import 'package:mess_erp/providers/announcement_provider.dart';

import '../helpers/mess_menu_helper.dart';

class CommitteeDashboardScreen extends StatefulWidget {
  static const routeName = '/committeeDashboard';
  const CommitteeDashboardScreen({super.key});

  @override
  State<CommitteeDashboardScreen> createState() =>
      _CommitteeDashboardScreenState();
}

class _CommitteeDashboardScreenState extends State<CommitteeDashboardScreen> {
  final AnnouncementServices announcementService = AnnouncementServices();
  @override
  void initState() {
    super.initState();
    AnnouncementServices().deleteOldAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Committee Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Committee Dashboard',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  MessMenuHelper.viewMessMenu();
                },
                child: const Text('Show Mess Menu'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
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
                                content: Text('Error Uploading Mess Menu'),
                              );
                            });
                      }
                    },
                  );
                },
                child: const Text('Upload Mess Menu'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(BillsScreen.routeName);
                },
                child: const Text('Show Bills'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/addAnnouncement');
                },
                child: const Text('Add Announcement'),
              ),
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

                      // Display announcements
                      return ListView.builder(
                        itemCount: announcements.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(announcements[index].title),
                            subtitle: Text(announcements[index].description),
                            onTap: () {
                              // Handle tap on announcement
                              bool openBill = false;
                              if (announcements[index].title == 'Mess Bill') {
                                openBill = true;
                              }
                              AnnouncementServices().openAnnouncement(
                                  announcements[index].file!.path,
                                  openBill: openBill);
                            },
                          );
                        },
                      );
                    }
                  },
                )),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/extraItems');
                },
                child: const Text('Extra Items'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/previousVouchers');
                },
                child: const Text('Previous Vouchers'),
              ),
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
