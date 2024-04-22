import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/manager/add_items_screen.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:provider/provider.dart';

import '../providers/vendor_provider.dart';

class ReceiveStockScreen extends StatefulWidget {
  static const routeName = '/receiveStock';
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

  @override
  void initState() {
    super.initState();
    fetchVendors();
  }

  void fetchVendors() async{
    await Provider.of<VendorProvider>(context, listen: false).fetchAndSetVendors();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  billNo = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Enter Bill No.'),
            ),
            const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: () async {
            //     final pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: selectedDate,
            //       firstDate: DateTime(2000),
            //       lastDate: DateTime.now(),
            //     );
            //     if (pickedDate != null && pickedDate != selectedDate) {
            //       setState(() {
            //         selectedDate = pickedDate;
            //       });
            //     }
            //   },
            //   child: const Text('Select Bill Date'),
            // ),
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
                    if (pickedDate != null && pickedDate != selectedDate) {
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

            // ElevatedButton(
            //   onPressed: () async {
            //     FilePickerResult? result =
            //         await FilePicker.platform.pickFiles(type: FileType.image);

            //     if (result != null) {
            //       setState(() {
            //         filePath = result.files.single.path;
            //       });
            //     }
            //   },
            //   child: const Text('Upload Bill Image'),
            // ),
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
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Bill'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItemScreen(onAddItem: addItem),
                  ),
                );
              },
              child: const Text('Add Items'),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: submitting
            ? null
            : () {
                setState(() {
                  submitting = true;
                });
                submitReceivedItems();
                setState(() {
                  submitting = false;
                });
              },
        child: Text(submitting ? 'Submitting' : 'Submit'),
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
  void submitReceivedItems() async {
    if (selectedVendor.isEmpty || billNo.isEmpty || receivedItems.isEmpty) {
      print('Please fill in all the required fields.');
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

      // Call the function to add the bill to Firestore
      // await addBillOfPurchase(
      //   vendorName: selectedVendor,
      //   billNumber: billNo,
      //   billDate: selectedDate,
      //   billImagePath: billImagePath,
      //   billAmount: totalBillAmount,
      //   approvalStatus: false, // Set approval status as needed
      //   remarks: 'No remarks', // Set remarks as needed
      // );
      Provider.of<BillsOfPurchaseProvider>(context, listen: false).addBill(
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
        const SnackBar(
          content: Text('Bill submitted successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting received items: $e');
    }
  }
}
