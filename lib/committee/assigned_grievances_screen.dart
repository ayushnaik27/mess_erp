import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/committee/view_grievance_details_committee.dart';
import 'package:provider/provider.dart';

import '../providers/grievance_provider.dart';

class AssignedGrievancesScreen extends StatelessWidget {
  final String userType;

  const AssignedGrievancesScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Grievances'),
      ),
      body: FutureBuilder<List<Grievance>>(
        future: Provider.of<GrievanceProvider>(context).fetchAssignedGrievances(
            userType), // Function to fetch assigned grievances
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Grievance> grievances = snapshot.data ?? [];
            return ListView.builder(
              itemCount: grievances.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(grievances[index].grievanceTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Date: ${DateFormat.yMMMMd().format(grievances[index].dateOfFiling)} at ${DateFormat.jm().format(grievances[index].dateOfFiling)}'),
                      Text('Title: ${grievances[index].grievanceTitle}'),
                      Text('Status: ${grievances[index].status}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GrievanceDetailsForCommitteeScreen(
                                  grievance: grievances[index],
                                  userType: userType),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (grievances[index].status == 'pending') {
                          return Colors.red;
                        } else if (grievances[index].status == 'resolved') {
                          return Colors.green;
                        } else if (grievances[index].status == 'reopened') {
                          return Colors.yellow;
                        }
                        return Colors.blue; // Default color
                      }),
                    ),
                    child: const Text('View Details'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  
}
