import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/vendor_provider.dart';
import 'package:mess_erp/vendor/file_bid_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/tender_provider.dart';

class TenderDetailsScreen extends StatelessWidget {
  final Tender tender;

  const TenderDetailsScreen({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String vendorId =
        Provider.of<VendorProvider>(context).currentVendorId;
    bool isVendorBidSubmitted =
        tender.bids.any((bid) => bid.vendorId == vendorId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tender.title,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deadline: ${dateFormat.format(tender.deadline)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Opening Date: ${dateFormat.format(tender.openingDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Items Required:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DataTable(columns: const [
              DataColumn(label: Text('Item')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Units')),
            ], rows: [
              ...tender.tenderItems.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.itemName)),
                  DataCell(Text(item.quantity.toString())),
                  DataCell(Text(item.units)),
                ]);
              }),
            ]),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Implement download tender functionality
                    final response = await get(Uri.parse(tender.fileUrl));
                    final bytes = response.bodyBytes;

                    final tempDir = await getTemporaryDirectory();
                    final tempDocumentPath =
                        '${tempDir.path}/${tender.title}.pdf';
                    await File(tempDocumentPath).writeAsBytes(bytes);

                    OpenFilex.open(tempDocumentPath);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                  child: Text('Download Tender',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary)),
                ),
                if (isVendorBidSubmitted)
                  const ElevatedButton(
                      onPressed: null, child: Text('Bid Submitted'))
                else
                  ElevatedButton(
                    onPressed: () {
                      // Implement file a bid functionality
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return FileBidScreen(tender);
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    child: Text('File a Bid',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
