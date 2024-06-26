import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/vendor/tender_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/tender_provider.dart';

class VendorDashboardScreen extends StatefulWidget {
  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshTenders();
  }

  void _refreshTenders() {
    final tenderProvider = Provider.of<TenderProvider>(context, listen: false);
    tenderProvider.fetchAndSetActiveTenders();
  }

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context);
    final List<Tender> activeTenders = tenderProvider.activeTenders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
      ),
      body: activeTenders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No active tenders available.'),
                Text('Please check back later.'),
              ],
            ))
          : ListView.builder(
              itemCount: activeTenders.length,
              itemBuilder: (context, index) {
                final tender = activeTenders[index];
                return ListTile(
                  title: Text(
                    tender.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline: ${DateFormat('dd-MM-yyyy').format(tender.deadline)}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        'Opening Date: ${DateFormat('dd-MM-yyyy').format(tender.openingDate)}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        'Items Required:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tender.tenderItems.map((item) {
                          return Text(
                            '- ${item.itemName}: ${item.quantity} ${item.units}',
                            style: Theme.of(context).textTheme.labelMedium,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the details screen for the selected tender
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return TenderDetailsScreen(tender: tender);
                    }));
                  },
                );
              },
            ),
    );
  }
}
