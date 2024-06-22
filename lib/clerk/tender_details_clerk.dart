import 'package:flutter/material.dart';
import '../providers/tender_provider.dart';

class TenderDetailsClerkScreen extends StatelessWidget {
  final Tender tender;
  final List<Bid> bids;

  const TenderDetailsClerkScreen(
      {Key? key, required this.tender, required this.bids})
      : super(key: key);

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

            // Find all bids with the lowest price
            final lowestBids = itemBids.where((bid) =>
                bid.itemPrices[item.itemName] ==
                (lowestBid?.itemPrices[item.itemName]));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item: ${item.itemName}, Quantity: ${item.quantity} ${item.units}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Sr No')),
                    DataColumn(label: Text('Company Name')),
                    DataColumn(label: Text('Price')),
                  ],
                  rows: itemBids
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          cells: [
                            DataCell(Text(
                              (entry.key + 1).toString(),
                              style: Theme.of(context).textTheme.labelMedium,
                            )),
                            DataCell(Text(entry.value.vendorName,
                                style:
                                    Theme.of(context).textTheme.labelMedium)),
                            DataCell(Text(
                                entry.value.itemPrices[item.itemName]!
                                    .toString(),
                                style:
                                    Theme.of(context).textTheme.labelMedium)),
                          ],
                        ),
                      )
                      .toList(),
                ),
                if (lowestBid != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      const Text(
                        'Lowest Bid:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      for (final bid in lowestBids)
                        Text(
                          '${bid.vendorName} (${bid.itemPrices[item.itemName]} ${item.units})',
                        ),
                    ],
                  ),
                const SizedBox(height: 32.0),
              ],
            );
          },
        ),
      ),
    );
  }
}
