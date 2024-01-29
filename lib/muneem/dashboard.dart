import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';
import '../providers/user_provider.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/approveExtraItems');
              },
              child: const Text('Approve Extra Items'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showAdaptiveDialog(
                    context: context,
                    builder: (context) => ImposeExtraDialog());
              },
              child: const Text('Impose Extra Amount'),
            ),
          ],
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
          child: const Text('Cancel'),
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
          child: const Text('Impose Extra'),
        ),
      ],
    );
  }
}
