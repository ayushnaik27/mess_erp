import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:provider/provider.dart';

import 'approve_or_reject_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  static const routeName = 'billsScreen';
  const BillsScreen({Key? key}) : super(key: key);

  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  // Dummy list of bills
  // List<Map<String, dynamic>> bills = [
  //   {'billNo': '1', 'vendorName': 'Vendor A', 'approvalStatus': 'pending'},
  //   {'billNo': '2', 'vendorName': 'Vendor B', 'approvalStatus': 'pending'},
  //   // Add more bills as needed
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills for Approval'),
      ),
      body: FutureBuilder(
          future: Provider.of<BillsOfPurchaseProvider>(context, listen: false)
              .fetchBills(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>>? bills = snapshot.data;
            // print(bills![0]);
            return bills == null || bills.isEmpty
                ? const Center(child: Text('No bills to approve'))
                : ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      String approvalStatus = bill['approvalStatus'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ApproveOrRejectBillScreen(billDetails: bill),
                            ),
                          );
                        },
                        child: ListTile(
                            title: Text('Bill No: ${bill['billNumber']}'),
                            subtitle: Text('Vendor: ${bill['vendorName']}'),
                            trailing: approvalStatus == 'approved'
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.pending,
                                    color: Colors.red,
                                  )),
                      );
                    },
                  );
          }),
    );
  }
}
