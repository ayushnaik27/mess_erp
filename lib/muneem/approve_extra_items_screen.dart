import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';

class ApproveExtraItemsScreen extends StatelessWidget {
  static const routeName = '/approveExtraItems';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Extra Items'),
      ),
      body: StreamBuilder(
        stream: Provider.of<ExtraItemsProvider>(context, listen: true)
            .fetchExtraItemRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ExtraItemRequest> requests = snapshot.data!;

          if (requests.isEmpty) {
            return const Center(child: Text('No requests to approve'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return ListTile(
                title: Text(request.itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${request.quantity}'),
                    Text('Roll Number: ${request.rollNumber}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Provider.of<ExtraItemsProvider>(context, listen: false)
                        .approveExtraItemRequest(
                            itemName: request.itemName,
                            quantity: request.quantity,
                            rollNumber: request.rollNumber,
                            requestId: request.id,
                            amount: request.amount);
                  },
                  child: const Text('Approve'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
