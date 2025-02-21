import 'package:flutter/material.dart';
import 'package:mess_erp/providers/voucher_provider.dart';
import 'package:provider/provider.dart';

import '../providers/vendor_name_provider.dart';

class PreviousVouchersScreen extends StatefulWidget {
  static const routeName = '/previousVouchers';
  const PreviousVouchersScreen({Key? key}) : super(key: key);

  @override
  _PreviousVouchersScreenState createState() => _PreviousVouchersScreenState();
}

class _PreviousVouchersScreenState extends State<PreviousVouchersScreen> {
  String selectedMonth = '';
  String selectedVendor = '';
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  void fetchVendors() async {
    await Provider.of<VendorNameProvider>(context, listen: false)
        .fetchAndSetVendorNames();
  }

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'Septemeber',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    final VendorNameProvider vendorProvider = Provider.of<VendorNameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Vouchers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                  setState(() {
                    clicked = false;
                  });
                });
              },
              items: const [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Select Month'),
                ),
                DropdownMenuItem<String>(
                  value: '1',
                  child: Text('January'),
                ),
                DropdownMenuItem<String>(
                  value: '2',
                  child: Text('February'),
                ),
                DropdownMenuItem<String>(
                  value: '3',
                  child: Text('March'),
                ),
                DropdownMenuItem<String>(
                  value: '4',
                  child: Text('April'),
                ),
                DropdownMenuItem<String>(
                  value: '5',
                  child: Text('May'),
                ),
                DropdownMenuItem<String>(
                  value: '6',
                  child: Text('June'),
                ),
                DropdownMenuItem<String>(
                  value: '7',
                  child: Text('July'),
                ),
                DropdownMenuItem<String>(
                  value: '8',
                  child: Text('August'),
                ),
                DropdownMenuItem<String>(
                  value: '9',
                  child: Text('September'),
                ),
                DropdownMenuItem<String>(
                  value: '10',
                  child: Text('October'),
                ),
                DropdownMenuItem<String>(
                  value: '11',
                  child: Text('November'),
                ),
                DropdownMenuItem<String>(
                  value: '12',
                  child: Text('December'),
                )
              ],
              hint: const Text('Select Month'),
            ),

            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedVendor,
              onChanged: (value) {
                setState(() {
                  selectedVendor = value!;
                  setState(() {
                    clicked = false;
                  });
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Select Vendor'),
                ),
                ...vendorProvider.getVendorNames().map((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor,
                    child: Text(vendor),
                  );
                }).toList(),
              ],
              hint: const Text('Select Vendor'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement logic to fetch and show vouchers for the selected month and vendor
                // Replace the below function call with your actual function
                setState(() {
                  clicked = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            // Implement the UI to show the fetched vouchers here
            const SizedBox(height: 16),

            clicked
                ? FutureBuilder(
                    future: Provider.of<PaymentVoucherProvider>(context,
                            listen: false)
                        .fetchPreviousVouchers(selectedMonth, selectedVendor),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error fetching vouchers'));
                      } else {
                        return snapshot.data!.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(snapshot.data![index]
                                          ['voucherNumber']),
                                      subtitle: Text(
                                          snapshot.data![index]['vendorName']),
                                      trailing: TextButton(
                                          onPressed: () {
                                            Provider.of<PaymentVoucherProvider>(
                                                    context,
                                                    listen: false)
                                                .viewVoucher(
                                                    snapshot.data![index]
                                                        ['pdfUrl'],
                                                    snapshot.data![index]
                                                        ['voucherNumber']);
                                          },
                                          child: const Text('View')),
                                    );
                                  },
                                ),
                              )
                            : const Center(child: Text('No vouchers found'));
                      }
                    })
                : Container(),
          ],
        ),
      ),
    );
  }
}
