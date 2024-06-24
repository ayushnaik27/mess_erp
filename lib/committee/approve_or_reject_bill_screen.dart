import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:provider/provider.dart';

class ApproveOrRejectBillScreen extends StatefulWidget {
  final Map<String, dynamic> billDetails;

  const ApproveOrRejectBillScreen({Key? key, required this.billDetails})
      : super(key: key);

  @override
  State<ApproveOrRejectBillScreen> createState() =>
      _ApproveOrRejectBillScreenState();
}

class _ApproveOrRejectBillScreenState extends State<ApproveOrRejectBillScreen> {
  TextEditingController remarksController = TextEditingController();
  bool _isChecked = false;
  bool viewing = false;
  @override
  Widget build(BuildContext context) {
    Timestamp billDate = widget.billDetails['billDate'];
    DateTime date = billDate.toDate();
    bool isRejected = widget.billDetails['approvalStatus'] == 'rejected';
    bool approvalStatus =
        widget.billDetails['approvalStatus'] == 'approved' ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Number ${widget.billDetails['billNumber']}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}'),
                      Text('Vendor: ${widget.billDetails['vendorName']}'),
                      Text(
                        'Bill Amount: ${widget.billDetails['billAmount']}',
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  TextButton.icon(
                    onPressed: viewing
                        ? null
                        : () async {
                            setState(() {
                              viewing = true;
                            });
                            await Provider.of<BillsOfPurchaseProvider>(context,
                                    listen: false)
                                .viewBill(widget.billDetails['billImagePath'],
                                    widget.billDetails['billNumber']);
                            setState(() {
                              viewing = false;
                            });
                          },
                    icon: Icon(Icons.remove_red_eye_outlined,
                        color: Theme.of(context).colorScheme.tertiary),
                    label: Text(
                      viewing ? 'Viewing' : 'View Bill',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Received Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 500,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.billDetails['receivedItems'].length,
                  itemBuilder: (context, index) {
                    final item = widget.billDetails['receivedItems'][index];
                    final double itemAmount =
                        item['quantityReceived'] * item['ratePerUnit'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item ${index + 1}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Item Name: ${item['itemName']}'),
                        Text('Quantity Received: ${item['quantityReceived']}'),
                        Text('Rate Per Unit: ${item['ratePerUnit']}'),
                        Text('Amount: $itemAmount'),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              approvalStatus
                  ? const Text(
                      'Bill Approved',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  : isRejected
                      ? const Text(
                          'Bill Rejected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the screen where the committee can provide remarks
                                showAdaptiveDialog(
                                    context: context,
                                    builder: ((context) {
                                      return AlertDialog(
                                        title: Text(
                                            'Do you want to reject bill number ${widget.billDetails['billNumber']}?'),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                                'Please provide remarks:'),
                                            TextField(
                                              controller: remarksController,
                                              decoration: const InputDecoration(
                                                labelText: 'Enter Remarks',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiary)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Call a function to update the approval status in Firestore
                                              await Provider.of<
                                                          BillsOfPurchaseProvider>(
                                                      context,
                                                      listen: false)
                                                  .rejectBill(
                                                widget
                                                    .billDetails['billNumber'],
                                                remarksController.text,
                                              );
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Bill rejected successfully'),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Theme.of(context)
                                                    .primaryColor),
                                            child: Text(
                                              'Reject',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary),
                                            ),
                                          ),
                                        ],
                                      );
                                    }));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor),
                              child: Text(
                                'Reject',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                await _showApprovalDialog(
                                    widget.billDetails['billNumber']);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor),
                              child: Text(
                                'Approve',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showApprovalDialog(String billNo) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Approve Bill'),
            // content: Text('Do you want to approve Bill No. $billNo?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Do you want to approve Bill No. $billNo?'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I declare that I have verified this bill correctly and all these items have been received in the mess. All the items are of best quality.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)),
              ),
              ElevatedButton(
                onPressed: _isChecked
                    ? () async {
                        // Call a function to update the approval status in Firestore
                        bool done = await Provider.of<BillsOfPurchaseProvider>(
                                context,
                                listen: false)
                            .approveBill(
                                widget.billDetails['billNumber'], context);
                        if (done) {
                          widget.billDetails['receivedItems']
                              .forEach((element) {
                            Provider.of<StockProvider>(context, listen: false)
                                .addStock(
                              itemName: element['itemName'],
                              transactionDate: DateTime.now(),
                              vendor: widget.billDetails['vendorName'],
                              receivedQuantity: element['quantityReceived'],
                              issuedQuantity: 0,
                              balance: element['quantityReceived'] *
                                  element['ratePerUnit'],
                            );
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bill approved successfully'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Yes',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
