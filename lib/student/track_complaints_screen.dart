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
    // Implement data retrieval logic here
    MyUser user =
        await Provider.of<UserProvider>(context, listen: false).getUser();
    await Provider.of<GrievanceProvider>(context, listen: false)
        .fetchGrievancesForStudents(user.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Complaints'),
      ),
      body: ListView.builder(
        itemCount: Provider.of<GrievanceProvider>(context).grievances.length,
        itemBuilder: (context, index) {
          final complaint =
              Provider.of<GrievanceProvider>(context).grievances[index];
          return ListTile(
            title: Text('ID: ${complaint.grievanceId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Date: ${DateFormat.yMMMMd().format(complaint.dateOfFiling)} at ${DateFormat.jm().format(complaint.dateOfFiling)}'),
                Text('Title: ${complaint.grievanceTitle}'),
                Text('Status: ${complaint.status}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to complaint details screen
                // Pass complaint details to the details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrievanceDetailScreen(
                        grievance: complaint, isStudent: true),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  _getStatusColor(complaint.status),
                ),
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
