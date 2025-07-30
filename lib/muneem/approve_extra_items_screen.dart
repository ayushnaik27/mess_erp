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
  final TextEditingController _searchController = TextEditingController();
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
                labelText: 'Search by Room Number',
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
                          request.roomNumber.contains(_searchQuery))
                      .toList();
                }

                if (requests.isEmpty) {
                  return const Center(child: Text('No requests to approve'));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity & Item Name (Priority 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  request.itemName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Qty: ${request.quantity}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 3),

                            // Room Number (Priority 2)
                            Text(
                              'Room: ${request.roomNumber}',
                              style: const TextStyle(

                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),

                            // Roll Number (Priority 3)
                            Text(
                              'Roll Number: ${request.rollNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Date & Time (Least Priority)
                            Text(
                              DateFormat('dd/MM/yyyy, hh:mm a')
                                  .format(request.timestamp),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600),
                            ),

                            const SizedBox(height: 8),

                            // Action Buttons (Aligned to Right)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Provider.of<ExtraItemsProvider>(context,
                                            listen: false)
                                        .deleteExtraItemRequest(request.id);
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Colors.grey.shade700),
                                  tooltip: "Delete Request",
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Provider.of<ExtraItemsProvider>(context,
                                            listen: false)
                                        .approveExtraItemRequest(
                                      itemName: request.itemName,
                                      quantity: request.quantity,
                                      rollNumber: request.rollNumber,
                                      requestId: request.id,
                                      amount: request.amount,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: Text(
                                    'Approve',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                  ),
                                ),
                              ],
                            ),
                          ],

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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        child: Text(
                          'Approve',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),

                        ),
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
