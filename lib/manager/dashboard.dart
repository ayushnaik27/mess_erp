import 'package:flutter/material.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/manager/track_bills_screen.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ManagerDashboardScreen extends StatelessWidget {
  static const routeName = '/managerDashboard';

  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context, listen: false).user;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder(
                  future: Provider.of<UserProvider>(context, listen: false)
                      .fetchUserDetails(arguments.toString(), role: 'manager'),
                  builder: (context, snapshot) => Text(
                    'Welcome ${user.name}',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/receiveStock');
                },
                child: const Text('Receive Stock'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/issueStock');
                },
                child: const Text('Issue Stock'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/generateVoucher');
                },
                child: const Text('Generate Voucher'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/previousVouchers');
                },
                child: const Text('Previous Vouchers'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('Hii');
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AssignedGrievancesScreen(userType: 'manager');
                  }));
                },
                child: const Text('View Assigned Grievances'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/viewAllGrievances');
                },
                child: const Text('View All Grievances'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TrackBillsScreen()));
                },
                child: const Text('Track Bills'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
