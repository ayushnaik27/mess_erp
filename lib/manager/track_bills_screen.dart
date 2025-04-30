<<<<<<< HEAD
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/manager/receive_stock_screen.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:provider/provider.dart';

class TrackBillsScreen extends StatefulWidget {
  @override
  _TrackBillsScreenState createState() => _TrackBillsScreenState();
}

class _TrackBillsScreenState extends State<TrackBillsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Bills'),
      ),
      body: Center(
          child: FutureBuilder(
              future:
                  Provider.of<BillsOfPurchaseProvider>(context, listen: false)
                      .fetchBills(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  log('Waiting for bills...');
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error fetching bills: ${snapshot.error}');
                } else {
                  if (snapshot.data == null) return Text('No bills found!');
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String status = snapshot.data![index]['approvalStatus'];
                      return ListTile(
                        title: Text(
                          snapshot.data![index]['billNumber'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(
                                snapshot.data![index]['billDate'].toDate()),
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing: IconButton(
                          icon: status == 'pending'
                              ? const Icon(Icons.pending_actions,
                                  color: Colors.orange)
                              : status == 'approved'
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : const Icon(Icons.cancel, color: Colors.red),
                          onPressed: status == 'rejected'
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReceiveStockScreen(
                                              billNumber: snapshot.data![index]
                                                  ['billNumber'],
                                            )),
                                  );
                                }
                              : null,
                        ),
                      );
                    },
                  );
                }
              })),
    );
  }
}
=======
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mess_erp/manager/receive_stock_screen.dart';
// import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
// import 'package:provider/provider.dart';

// class TrackBillsScreen extends StatefulWidget {
//   @override
//   _TrackBillsScreenState createState() => _TrackBillsScreenState();
// }

// class _TrackBillsScreenState extends State<TrackBillsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Track Bills'),
//       ),
//       body: Center(
//           child: FutureBuilder(
//               future:
//                   Provider.of<BillsOfPurchaseProvider>(context, listen: false)
//                       .fetchBills(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   log('Waiting for bills...');
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error fetching bills: ${snapshot.error}');
//                 } else {
//                   if (snapshot.data == null) return Text('No bills found!');
//                   return ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       String status = snapshot.data![index]['approvalStatus'];
//                       return ListTile(
//                         title: Text(
//                           snapshot.data![index]['billNumber'],
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         subtitle: Text(
//                             DateFormat('dd/MM/yyyy').format(
//                                 snapshot.data![index]['billDate'].toDate()),
//                             style: Theme.of(context).textTheme.bodySmall),
//                         trailing: IconButton(
//                           icon: status == 'pending'
//                               ? const Icon(Icons.pending_actions,
//                                   color: Colors.orange)
//                               : status == 'approved'
//                                   ? const Icon(Icons.check_circle,
//                                       color: Colors.green)
//                                   : const Icon(Icons.cancel, color: Colors.red),
//                           onPressed: status == 'rejected'
//                               ? () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             ReceiveStockScreen(
//                                               billNumber: snapshot.data![index]
//                                                   ['billNumber'],
//                                             )),
//                                   );
//                                 }
//                               : null,
//                         ),
//                       );
//                     },
//                   );
//                 }
//               })),
//     );
//   }
// }
>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
