import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';

class ApproveExtraItemsScreen extends StatefulWidget {
  static const routeName = '/approveExtraItems';

  @override
  _ApproveExtraItemsScreenState createState() =>
      _ApproveExtraItemsScreenState();
}

class _ApproveExtraItemsScreenState extends State<ApproveExtraItemsScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Extra Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Roll Number',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: Provider.of<ExtraItemsProvider>(context, listen: true)
                  .fetchExtraItemRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null) {
                  return const Center(child: Text('No requests to approve'));
                }
                List<ExtraItemRequest> requests = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  requests = requests
                      .where((request) =>
                          request.rollNumber.contains(_searchQuery))
                      .toList();
                }

                if (requests.isEmpty) {
                  return const Center(child: Text('No requests to approve'));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    return ListTile(
                      title: Text(
                        request.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${request.quantity}'),
                          Text('Roll Number: ${request.rollNumber}'),
                          Text(
                              DateFormat('dd/MM/yyyy')
                                  .add_jm()
                                  .format(request.timestamp),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Provider.of<ExtraItemsProvider>(context,
                                  listen: false)
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
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../providers/extra_item_provider.dart';

// class ApproveExtraItemsScreen extends StatelessWidget {
//   static const routeName = '/approveExtraItems';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Approve Extra Items'),
//       ),
//       body: StreamBuilder(
//         stream: Provider.of<ExtraItemsProvider>(context, listen: true)
//             .fetchExtraItemRequests(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           print(snapshot);

//           if (snapshot.data == null) {
//             return const Center(child: Text('No requests to approve'));
//           }
//           List<ExtraItemRequest> requests = snapshot.data!;

//           if (requests.isEmpty) {
//             return const Center(child: Text('No requests to approve'));
//           }

//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];

//               return ListTile(
//                 title: Text(
//                   request.itemName,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Quantity: ${request.quantity}'),
//                     Text('Roll Number: ${request.rollNumber}'),
//                     Text(
//                         DateFormat('dd/MM/yyyy')
//                             .add_jm()
//                             .format(request.timestamp),
//                         style:
//                             const TextStyle(fontSize: 10, color: Colors.grey)),
//                   ],
//                 ),
//                 trailing: ElevatedButton(
//                   onPressed: () {
//                     Provider.of<ExtraItemsProvider>(context, listen: false)
//                         .approveExtraItemRequest(
//                             itemName: request.itemName,
//                             quantity: request.quantity,
//                             rollNumber: request.rollNumber,
//                             requestId: request.id,
//                             amount: request.amount);
//                   },
//                   child: const Text('Approve'),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
