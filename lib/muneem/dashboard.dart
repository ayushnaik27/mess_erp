import 'package:flutter/material.dart';
import 'package:mess_erp/muneem/netx_three_meals_screen.dart';
import 'package:mess_erp/muneem/students_on_leave.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';
import '../providers/user_provider.dart';
import 'show_qr_screen.dart';

class MuneemDashboardScreen extends StatelessWidget {
  static const routeName = '/muneemDashboard';

  const MuneemDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    print(arguments.keys);
    print(arguments['email']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muneem Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        Navigator.of(context).pushNamed('/approveExtraItems');
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Approve Extra Items',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showAdaptiveDialog(
                            context: context,
                            builder: (context) => ImposeExtraDialog());
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.money),
                            const SizedBox(height: 16.0),
                            Text(
                              'Impose Extra Amount',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ShowQRScreen();
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code),
                            const SizedBox(height: 16.0),
                            Text(
                              'Show QR',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return StudentsOnLeaveScreen();
                        }));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.food_bank),
                            const SizedBox(height: 16.0),
                            Text(
                              'Students on Leave',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder(
                    future: Provider.of<UserProvider>(context, listen: false)
                        .fetchUserDetails(arguments['email']!, role: 'muneem'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data == null) {
                        return Container();
                      }
                      return Text(
                        'Welcome ${snapshot.data!.name}',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).pushNamed('/approveExtraItems');
              //   },
              //   child: const Text('Approve Extra Items'),
              // ),
              // const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     showAdaptiveDialog(
              //         context: context,
              //         builder: (context) => ImposeExtraDialog());
              //   },
              //   child: const Text('Impose Extra Amount'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context)
              //         .push(MaterialPageRoute(builder: (context) {
              //       return ShowQRScreen();
              //     }));
              //   },
              //   child: const Text('Show QR'),
              // ),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).push(MaterialPageRoute(
              //           builder: (context) => NextThreeMealsScreen()));
              //     },
              //     child: const Text('Next Three Meals'))
            ],
          ),
        ),
      ),
    );
  }
}

class ImposeExtraDialog extends StatefulWidget {
  @override
  _ImposeExtraDialogState createState() => _ImposeExtraDialogState();
}

class _ImposeExtraDialogState extends State<ImposeExtraDialog> {
  TextEditingController rollNumberController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Impose Extra Amount'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: rollNumberController,
            decoration: const InputDecoration(labelText: 'Student Roll Number'),
          ),
          TextField(
            controller: itemNameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // Close the dialog without imposing extra amount
          },
          child: Text('Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<ExtraItemsProvider>(context, listen: false)
                .addBillForStudent(
                    rollNumberController.text,
                    DateTime.now(),
                    itemNameController.text,
                    double.parse(amountController.text));
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Extra amount imposed')));
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          child: Text(
            'Impose',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        ),
      ],
    );
  }
}
