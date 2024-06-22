import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:mess_erp/providers/vendor_provider.dart';
import 'package:mess_erp/providers/voucher_provider.dart';
import 'package:provider/provider.dart';

class GenerateVoucherScreen extends StatefulWidget {
  static const routeName = '/generateVoucher';

  @override
  _GenerateVoucherScreenState createState() => _GenerateVoucherScreenState();
}

class _GenerateVoucherScreenState extends State<GenerateVoucherScreen> {
  String selectedMonth = ''; // Selected month from dropdown
  String selectedVendor = ''; // Selected vendor from dropdown
  String selectedDateRange = ''; // Selected month range from dropdown

  // Dummy lists (replace them with actual data from your backend)
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

  List<Map<String, dynamic>> bills = [
    // Add more bills as needed
  ];

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Voucher'),
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

            DropdownButton(
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Select Vendor'),
                  ),
                  ...vendorProvider.getVendorNames().map((vendorName) {
                    return DropdownMenuItem(
                      value: vendorName,
                      child: Text(vendorName),
                    );
                  }).toList()
                ],
                onChanged: (value) {
                  setState(() {
                    selectedVendor = value.toString();
                  });
                },
                hint: Text(
                    selectedVendor.isEmpty ? 'Select Vendor' : selectedVendor)),
            const SizedBox(height: 16),
            DropdownButton<String>(
                value: selectedDateRange,
                items: const [
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text('Select Date Range'),
                  ),
                  DropdownMenuItem<String>(
                    value: '0',
                    child: Text('Day 1 to 15'),
                  ),
                  DropdownMenuItem<String>(
                    value: '1',
                    child: Text('Day 16 to End of Month'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDateRange = value!;
                  });
                },
                hint: const Text('Select Month Range')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedMonth.isEmpty ||
                    selectedVendor.isEmpty ||
                    selectedDateRange.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select all fields!')));
                  return;
                }
                if(bills.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('There are no bills to generate voucher for!')));
                  return;
                }
                // Perform logic to fetch bills and generate vouchers
                Provider.of<PaymentVoucherProvider>(context, listen: false)
                    .generateVoucher(selectedDateRange, bills);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Voucher generated successfully!')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Generate Voucher',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),

            const SizedBox(height: 16),
            // Display the fetched bills
            if (selectedDateRange != '')
              FutureBuilder(
                  future: Provider.of<BillsOfPurchaseProvider>(context,
                          listen: false)
                      .fetchBillsForVoucher(
                          selectedMonth, selectedVendor, selectedDateRange),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('An error occurred!'));
                    } else {
                      bills = snapshot.data as List<Map<String, dynamic>>;
                    }

                    return bills.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Serial Number')),
                                DataColumn(label: Text('Bill Number')),
                                DataColumn(label: Text('Bill Date')),
                                DataColumn(label: Text('Amount')),
                              ],
                              rows: bills.map((bill) {
                                final serialNumber = bills.indexOf(bill) + 1;
                                final formattedDate = DateFormat('dd-MM-yyyy')
                                    .format(bill['billDate'].toDate());
                                return DataRow(
                                  cells: [
                                    DataCell(Text(serialNumber.toString())),
                                    DataCell(Text(bill['billNumber'])),
                                    DataCell(Text(formattedDate)),
                                    DataCell(
                                        Text(bill['billAmount'].toString())),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : const Center(child: Text('No bills found!'));
                  }),
            // if (bills.isNotEmpty)
            //   SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: DataTable(
            //       columns: const [
            //         DataColumn(label: Text('Serial Number')),
            //         DataColumn(label: Text('Bill Number')),
            //         DataColumn(label: Text('Bill Date')),
            //         DataColumn(label: Text('Amount')),
            //       ],
            //       rows: bills.map((bill) {
            //         return DataRow(
            //           cells: [
            //             DataCell(Text(bill['serialNumber'].toString())),
            //             DataCell(Text(bill['billNumber'])),
            //             DataCell(Text(bill['billDate'])),
            //             DataCell(Text(bill['amount'].toString())),
            //           ],
            //         );
            //       }).toList(),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
