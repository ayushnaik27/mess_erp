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
    Timestamp? timestamp;

    if (messBill.extraList.isNotEmpty) {
      timestamp = messBill.extraList[0]['date'] as Timestamp?;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${messBill.month} Mess Bill Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildInfoRow('Total Amount: ', '₹${messBill.totalAmount}'),
            const SizedBox(height: 10),
            _buildInfoRow('Total Diets: ', '${messBill.totalDiets}'),
            const SizedBox(height: 10),
            _buildInfoRow('Total Extra: ', '₹${messBill.totalExtra}'),
            const SizedBox(height: 10),
            if (messBill.extraList.isNotEmpty && timestamp != null)
              _buildExtraItemsTable(timestamp, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildExtraItemsTable(Timestamp timestamp, BuildContext context) {
    return DataTable(
      dataRowMaxHeight: 100,
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Particulars')),
        DataColumn(label: Text('Amount')),
      ],
      rows: [
        for (var extra in messBill.extraList)
          for (var item in extra['items'])
            DataRow(cells: [
              DataCell(Text(
                  'At ${DateFormat.jm().format(extra['date'].toDate())} on ${DateFormat.yMMMMd().format(extra['date'].toDate())}',
                  style: Theme.of(context).textTheme.labelMedium)),
              DataCell(Text(item['item'],
                  style: Theme.of(context).textTheme.bodySmall)),
              DataCell(Text('₹${item['amount']}',
                  style: Theme.of(context).textTheme.bodySmall)),
            ]),
      ],
    );
  }
}
