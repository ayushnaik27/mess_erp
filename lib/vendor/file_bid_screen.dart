// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mess_erp/providers/vendor_provider.dart';
// import 'package:provider/provider.dart';
// import '../providers/tender_provider.dart';

// class FileBidScreen extends StatefulWidget {
//   final Tender tender;

//   const FileBidScreen(this.tender, {super.key});

//   @override
//   _FileBidScreenState createState() => _FileBidScreenState();
// }

// class _FileBidScreenState extends State<FileBidScreen> {
//   List<TextEditingController> _priceControllers = [];
//   List<double> _totalPrices = [];

//   @override
//   void initState() {
//     super.initState();
//     _priceControllers = List.generate(
//       widget.tender.tenderItems.length,
//       (index) => TextEditingController(),
//     );
//     _totalPrices = List.filled(widget.tender.tenderItems.length, 0.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('File a Bid'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Tender Details:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8.0),
//               Text(
//                 widget.tender.title,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 18.0),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Deadline: ${dateFormat.format(widget.tender.deadline)}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 'Opening Date: ${dateFormat.format(widget.tender.openingDate)}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16.0),
//               const Text(
//                 'Bid Form:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8.0),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: DataTable(
//                   columnSpacing: 10,
//                   dataRowMaxHeight: 50,
//                   columns: const [
//                     DataColumn(label: Text('Sr No')),
//                     DataColumn(label: Text('Item')),
//                     DataColumn(label: Text('Quantity')),
//                     DataColumn(label: Text('Units')),
//                     DataColumn(label: Text('Price per Unit')),
//                     DataColumn(label: Text('Total Price')),
//                   ],
//                   rows: [
//                     ...widget.tender.tenderItems.map((item) {
//                       return DataRow(cells: [
//                         DataCell(Text(
//                             (widget.tender.tenderItems.indexOf(item) + 1)
//                                 .toString())),
//                         DataCell(Text(item.itemName)),
//                         DataCell(Text(item.quantity.toString())),
//                         DataCell(Text(item.units)),
//                         DataCell(
//                           Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 decoration: const InputDecoration(
//                                   border: OutlineInputBorder(),
//                                   contentPadding: EdgeInsets.all(8.0),
//                                 ),
//                                 controller: _priceControllers[
//                                     widget.tender.tenderItems.indexOf(item)],
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) {
//                                   double pricePerUnit =
//                                       double.tryParse(value) ?? 0.0;
//                                   double total = pricePerUnit * item.quantity;
//                                   setState(() {
//                                     _totalPrices[widget.tender.tenderItems
//                                         .indexOf(item)] = total;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataCell(Text(_totalPrices[
//                                 widget.tender.tenderItems.indexOf(item)]
//                             .toString())),
//                       ]);
//                     }),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               Text(
//                 'Total: ${_totalPrices.reduce((value, element) => value + element)}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 48.0),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_priceControllers
//                         .any((controller) => controller.text.isEmpty)) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('Please fill all the fields'),
//                       ));
//                       return;
//                     }
//                     // Implement bid submission functionality
//                     String vendorId =
//                         Provider.of<VendorProvider>(context, listen: false)
//                             .currentVendorId;
//                     Vendor currentVendor = Provider.of<VendorProvider>(
//                       context,
//                       listen: false,
//                     ).currentVendor;

//                     print('Company Name ${currentVendor.companyName}');
//                     Bid bid = Bid(
//                       vendorId: vendorId,
//                       vendorName: currentVendor.companyName,
//                       totalPrice: _totalPrices
//                           .reduce((value, element) => value + element),
//                       itemPrices: Map.fromIterables(
//                         widget.tender.tenderItems.map((item) => item.itemName),
//                         _totalPrices,
//                       ),
//                     );

//                     print('Bid: ${bid.toMap()}');

//                     try {
//                       await Provider.of<TenderProvider>(context, listen: false)
//                           .submitBid(widget.tender.tenderId, bid);
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('Bid submitted successfully'),
//                       ));
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('Failed to submit bid'),
//                       ));
//                       return;
//                     }
//                   },
//                   child: const Text('Submit Bid'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _priceControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
