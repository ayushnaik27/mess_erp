import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mess_erp/manager/add_items_screen.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:mess_erp/providers/vendor_name_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
class ReceiveStockScreen extends StatefulWidget {
  static const routeName = '/receiveStock';
  final String? billNumber;

  const ReceiveStockScreen({super.key, this.billNumber});
  @override
  _ReceiveStockScreenState createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  String selectedVendor = '';
  String billNo = '';
  DateTime selectedDate = DateTime.now();
  List<ItemEntry> receivedItems = [];
  String? filePath;
  bool submitting = false;
  bool editing = false;
  final TextEditingController _billController = TextEditingController();
  bool loading = false;
  String remarks = '';

  @override
  void initState() {
    super.initState();
    fetchVendors();

    if (widget.billNumber != null) {
      setState(() {
        loading = true;
      });

      Future.delayed(Duration.zero, () {
        setBillDetails().then((_) {
          setState(() {
            loading = false;
          });
        });
      });
    }
  }

  Future<void> setBillDetails() async {
    final bill = Provider.of<BillsOfPurchaseProvider>(context, listen: false)
        .getBillByNumber(widget.billNumber!);

    String fileUrl = bill['billImagePath'];

    final response = await http.get(
      Uri.parse(fileUrl),
    );
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/${widget.billNumber}jpg';
    await File(tempDocumentPath).writeAsBytes(bytes);

    setState(() {
      selectedVendor = bill['vendorName'];
      billNo = bill['billNumber'];
      selectedDate = bill['billDate'].toDate();
      receivedItems = bill['receivedItems']
          .map<ItemEntry>((item) => ItemEntry(
                itemName: item['itemName'],
                ratePerUnit: item['ratePerUnit'],
                quantityReceived: item['quantityReceived'],
              ))
          .toList();
      _billController.text = billNo;
      filePath = tempDocumentPath;
      editing = true;
      remarks = bill['remarks'];
    });
  }

  void fetchVendors() async {
    await Provider.of<VendorNameProvider>(context, listen: false)
        .fetchAndSetVendorNames();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorNameProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Stock'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  editing
                      ? Card(
                          color: Colors.red.shade100,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 16.0,
                                bottom: 8.0,
                                right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Remarks: $remarks',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
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
                      hint: Text(selectedVendor.isEmpty
                          ? 'Select Vendor'
                          : selectedVendor)),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _billController,
                    enabled: !editing,
                    onChanged: editing
                        ? null
                        : (value) {
                            setState(() {
                              billNo = value;
                            });
                          },
                    decoration: InputDecoration(
                      labelText: 'Enter Bill No.',
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: filePath != null
                            ? Image(
                                image: FileImage(File(filePath!)),
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Text('Preview'),
                              ),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);

                          if (result != null) {
                            setState(() {
                              filePath = result.files.single.path;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        icon: Icon(Icons.upload,
                            color: Theme.of(context).colorScheme.tertiary),
                        label: Text('Upload Bill',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddItemScreen(onAddItem: addItem),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('Add Items',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary)),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: receivedItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(receivedItems[index].itemName),
                            subtitle: Text(
                              'Rate: ${receivedItems[index].ratePerUnit}, Quantity: ${receivedItems[index].quantityReceived}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  receivedItems.removeAt(index);
                                });
                              },
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: loading
          ? const SizedBox()
          : ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setState(() {
                        submitting = true;
                      });
                      await submitReceivedItems();
                      setState(() {
                        submitting = false;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: editing
                  ? Text(
                      submitting ? 'Updating' : 'Update',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    )
                  : Text(
                      submitting ? 'Submitting' : 'Submit',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
            ),
    );
  }

  // Function to add an item to the receivedItems list
  void addItem(ItemEntry item) {
    setState(() {
      receivedItems.add(item);
    });
  }

  // Submit received items to table 4
  Future<void> submitReceivedItems() async {
    if (filePath == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: const Text('Please upload the bill image.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (selectedVendor.isEmpty || billNo.isEmpty || receivedItems.isEmpty) {
      log('Please fill in all the required fields.');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: const Text('Please fill all the fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      String billImagePath = '';

      final storageRef =
          FirebaseStorage.instance.ref().child('billOfPurchase/$billNo');
      await storageRef.putFile(File(filePath!));
      final downloadUrl = await storageRef.getDownloadURL();
      billImagePath = downloadUrl;

      //total bill amount based on received items
      double totalBillAmount = receivedItems.fold(
          0.0, (sum, item) => sum + (item.ratePerUnit * item.quantityReceived));

      editing
          ? await Provider.of<BillsOfPurchaseProvider>(context, listen: false)
              .updateBill(
                  billNumber: billNo,
                  vendorName: selectedVendor,
                  billDate: selectedDate,
                  billImagePath: billImagePath,
                  billAmount: totalBillAmount,
                  approvalStatus: 'pending',
                  remarks: '',
                  receivedItems: receivedItems)
          : await Provider.of<BillsOfPurchaseProvider>(context, listen: false)
              .addBill(
                  vendorName: selectedVendor,
                  billNumber: billNo,
                  billDate: selectedDate,
                  billImagePath: billImagePath,
                  billAmount: totalBillAmount,
                  approvalStatus: 'pending',
                  remarks: 'No remarks',
                  receivedItems: receivedItems);

      // Reset the state after successful submission
      setState(() {
        selectedVendor = '';
        billNo = '';
        selectedDate = DateTime.now();
        receivedItems.clear();
        filePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: editing
              ? const Text('Bill updated successfully')
              : const Text('Bill submitted successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      log('Error submitting received items: $e');
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Error submitting received items. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
    }
  }
}
