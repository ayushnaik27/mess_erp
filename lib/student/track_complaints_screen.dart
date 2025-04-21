import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../providers/grievance_provider.dart';
import 'grievance_detail_screen.dart';

class TrackComplaintScreen extends StatefulWidget {
  static const routeName = '/trackComplaints';

  const TrackComplaintScreen({super.key});
  @override
  _TrackComplaintScreenState createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  // Function to fetch complaints data
  Future<void> fetchComplaints() async {
    MyUser user =
        await Provider.of<UserProvider>(context, listen: false).getUser();
    await Provider.of<GrievanceProvider>(context, listen: false)
        .fetchGrievancesForStudents(user.username);
  }

  @override
  Widget build(BuildContext context) {
    final grievances = Provider.of<GrievanceProvider>(context).grievances;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Complaints'),
      ),
      body: grievances.isEmpty
          ? const Center(
              child: Text("No Grievances Filed"),
            )
          : ListView.builder(
              itemCount: grievances.length,
              itemBuilder: (context, index) {
                final complaint = grievances[index];
                log(grievances.length.toString());
                return ListTile(
                  title: Text(
                    'ID: ${complaint.grievanceId}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${DateFormat.yMMMMd().format(complaint.dateOfFiling)} at ${DateFormat.jm().format(complaint.dateOfFiling)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Title: ${complaint.grievanceTitle}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Status: ${complaint.status}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrievanceDetailScreen(
                            grievance: complaint,
                            isStudent: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(complaint.status),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Helper function to get color based on complaint status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red;
      case 'resolved':
        return Colors.green;
      case 'in process':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
