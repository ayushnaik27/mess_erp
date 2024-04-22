import 'package:flutter/material.dart';
import '../providers/tender_provider.dart';

class TenderDetailsClerkScreen extends StatelessWidget {
  final Tender tender;
  final List<Bid> bids;

  const TenderDetailsClerkScreen(
      {super.key, required this.tender, required this.bids});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tender Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tender.tenderItems.length,
          itemBuilder: (context, index) {
            final item = tender.tenderItems[index];
            final itemBids = bids
                .where((bid) => bid.itemPrices.containsKey(item.itemName))
                .toList();

            // Sorting bids for the current item by price
            itemBids.sort((a, b) => a.itemPrices[item.itemName]!
                .compareTo(b.itemPrices[item.itemName]!));

            // Get the lowest bid for the current item
            final lowestBid = itemBids.isNotEmpty ? itemBids.first : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item: ${item.itemName}, Quantity: ${item.quantity} ${item.units}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Sr No')),
                    DataColumn(label: Text('Company Name')),
                    DataColumn(label: Text('Price')),
                  ],
                  rows: itemBids
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          cells: [
                            DataCell(Text((entry.key + 1).toString())),
                            DataCell(Text(entry.value.vendorName)),
                            DataCell(Text(entry.value.itemPrices[item.itemName]!
                                .toString())),
                          ],
                        ),
                      )
                      .toList(),
                ),
                if (lowestBid != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Lowest Bid: ${lowestBid.vendorName} (${lowestBid.itemPrices[item.itemName]} ${item.units})',
                    ),
                  ),
                
                const SizedBox(height: 32.0)
              ],
            );
          },
        ),
      ),
    );
  }
}
