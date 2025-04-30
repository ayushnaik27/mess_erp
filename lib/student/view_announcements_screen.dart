import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ViewAnnouncementsScreen extends StatefulWidget {
  const ViewAnnouncementsScreen({super.key});
  static const routeName = '/viewAnnouncements';

  @override
  State<ViewAnnouncementsScreen> createState() =>
      _ViewAnnouncementsScreenState();
}

class _ViewAnnouncementsScreenState extends State<ViewAnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('loginCredentials')
                  .doc('roles')
                  .collection('student')
                  .doc(user.username)
                  .collection('announcements')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null) {
                  return const Center(child: Text('No announcements'));
                }
                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    announcements = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index].data();
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(announcement['title'],
                            style: Theme.of(context).textTheme.bodyMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement['message'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .add_jm()
                                  .format(announcement['timestamp'].toDate()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
