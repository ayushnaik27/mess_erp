import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';

class MessBillDetailsScreen extends StatelessWidget {
  final MessBill messBill;

  const MessBillDetailsScreen({Key? key, required this.messBill})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = messBill.extraList[0]['date'] as Timestamp;

    return Scaffold(
      appBar: AppBar(
        title: Text('${messBill.month} Mess Bill Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text('₹${messBill.totalAmount}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Diets: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text('${messBill.totalDiets}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Extra: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text('₹${messBill.totalExtra}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            if (messBill.totalAmount > 0)
              DataTable(
                dataRowMaxHeight: 100,
                columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Particulars')),
                DataColumn(label: Text('Amount')),
              ], rows: [
                for (var extra in messBill.extraList)
                  for (var item in extra['items'])
                    DataRow(cells: [
                      DataCell(Text('At ${DateFormat.jm().format(timestamp.toDate())} on ${DateFormat.yMMMd().format(timestamp.toDate())}')),
                      DataCell(Text(item['item'])),
                      DataCell(Text('₹${item['amount']}')),
                    ]),
              ])

            // Add necessary logic to fetch mess bill details and other functionalities
          ],
        ),
      ),
    );
  }
}
