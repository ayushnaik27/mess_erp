import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/manager/track_bills_screen.dart';
import 'package:mess_erp/widgets/change_password_dialog.dart';
import 'package:provider/provider.dart';

import '../muneem/netx_three_meals_screen.dart';
import '../providers/hash_helper.dart';
import '../providers/user_provider.dart';

class ManagerDashboardScreen extends StatelessWidget {
  static const routeName = '/managerDashboard';

  const ManagerDashboardScreen({Key? key}) : super(key: key);

  void changePassword(String newPassword) async {
    String hashedPassword = HashHelper.encode(newPassword);
    await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('manager')
        .doc('manager@gmail.com')
        .update({
      'password': hashedPassword,
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<UserProvider>(context, listen: false).user;

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
                    child: const Text('P'),
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
                'Receive Stock',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/receiveStock');
              },
            ),
            ListTile(
              title: Text(
                'Issue Stock',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/issueStock');
              },
            ),
            ListTile(
              title: Text(
                'Generate Voucher',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/generateVoucher');
              },
            ),
            ListTile(
              title: Text(
                'Previous Vouchers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/previousVouchers');
              },
            ),
            ListTile(
              title: Text(
                'View Assigned Grievances',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AssignedGrievancesScreen(userType: 'manager');
                }));
              },
            ),
            ListTile(
              title: Text(
                'View All Grievances',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/viewAllGrievances');
              },
            ),
            ListTile(
              title: Text(
                'Track Bills',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TrackBillsScreen()));
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
                'Logout',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                child: Text(
                  'Welcome ${capitalize(Provider.of<UserProvider>(context).user.name)}',
                  style: Theme.of(context).textTheme.titleLarge,
                )),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: FutureBuilder(
            //     future: Provider.of<UserProvider>(context, listen: false)
            //         .fetchUserDetails(arguments.toString(), role: 'manager'),
            //     builder: (context, snapshot) => Text(
            //       'Welcome ${user.name}',
            //       style: const TextStyle(
            //         fontSize: 24.0,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20.0),
            Padding(
                padding: const EdgeInsets.all(8),
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
                        Navigator.of(context).pushNamed('/receiveStock');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Receive Stock',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/issueStock');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Issue Stock',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/generateVoucher');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Generate Voucher',
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
                            const Icon(Icons.food_bank),
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
                              userType: 'manager');
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'View Assigned Grievances',
                              textAlign: TextAlign.center,
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
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'View All Grievances',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TrackBillsScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Track Bills',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NextThreeMealsScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Next Three Meals',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/receiveStock');
            //   },
            //   child: const Text('Receive Stock'),
            // ),
            // const SizedBox(height: 20.0),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/issueStock');
            //   },
            //   child: const Text('Issue Stock'),
            // ),
            // const SizedBox(height: 20.0),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/generateVoucher');
            //   },
            //   child: const Text('Generate Voucher'),
            // ),
            // const SizedBox(height: 20.0),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/previousVouchers');
            //   },
            //   child: const Text('Previous Vouchers'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     print('Hii');
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return const AssignedGrievancesScreen(userType: 'manager');
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
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => TrackBillsScreen()));
            //   },
            //   child: const Text('Track Bills'),
            // ),
          ],
        ),
      ),
    );
  }
}
