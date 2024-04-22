// TrackComplaintScreen
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/student/grievance_detail_screen.dart';
import 'package:provider/provider.dart';

import '../providers/grievance_provider.dart';

class AllGrievancesScreen extends StatefulWidget {
  static const routeName = '/viewAllGrievances';

  const AllGrievancesScreen({super.key});
  @override
  _AllGrievancesScreenState createState() => _AllGrievancesScreenState();
}

class _AllGrievancesScreenState extends State<AllGrievancesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch grievances registered by the student in the previous 2 months
    fetchGrievances();
  }

  Future<void> fetchGrievances() async {
    // Implement fetching grievances from Firestore or any other source
    // Update the grievances list
    await Provider.of<GrievanceProvider>(context, listen: false)
        .fetchAllGrievances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Grievances'),
      ),
      body: ListView.builder(
        itemCount: Provider.of<GrievanceProvider>(context).grievances.length,
        itemBuilder: (context, index) {
          final grievance =
              Provider.of<GrievanceProvider>(context).grievances[index];
          Color statusColor = getStatusColor(grievance.status);
          return ListTile(
            title: Text('ID: ${grievance.grievanceId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Date: ${DateFormat.yMMMMd().format(grievance.dateOfFiling)} at ${DateFormat.jm().format(grievance.dateOfFiling)}'),
                Text('Title: ${grievance.grievanceTitle}'),
                Text('Status: ${grievance.status}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to ViewDetailsScreen with the selected grievance
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GrievanceDetailScreen(grievance: grievance, isStudent: false),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(primary: statusColor),
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

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
