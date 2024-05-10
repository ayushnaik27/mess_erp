import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../manager/add_items_screen.dart';
import 'stock_provider.dart';

class BillsOfPurchaseProvider extends ChangeNotifier {
  final CollectionReference _billsCollection =
      FirebaseFirestore.instance.collection('billsOfPurchase');

  List<Map<String, dynamic>> _bills = [];

  List<Map<String, dynamic>> get bills => _bills;

  Future<void> viewBill(String url, String billNumber) async {
    final response = await http.get(
      Uri.parse(url),
    );
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$billNumber.jpg';

    await File(tempDocumentPath).writeAsBytes(bytes);
    OpenFilex.open(tempDocumentPath);
  }

  Map<String, dynamic> getBillByNumber(String billNumber) {
    return _bills.firstWhere((bill) => bill['billNumber'] == billNumber);
  }

  Future<List<Map<String, dynamic>>> fetchBills() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _billsCollection.orderBy('billDate', descending: true).get()
              as QuerySnapshot<Map<String, dynamic>>;
      _bills = snapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
          .toList();

      notifyListeners();
      return _bills;
    } catch (e) {
      print('Error fetching bills: $e');
      rethrow;
    }
  }

  Future<bool> approveBill(String billNumber, BuildContext context) async {
    try {
      FirebaseFirestore.instance
          .collection('billsOfPurchase')
          .doc(billNumber)
          .update({'approvalStatus': 'approved'});
      await fetchBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> rejectBill(String billNumber, String remarks) async {
    try {
      await FirebaseFirestore.instance
          .collection('billsOfPurchase')
          .doc(billNumber)
          .update({'approvalStatus': 'rejected', 'remarks': remarks});
      await fetchBills();
    } catch (e) {
      print('Error rejecting bill: $e');
    }
  }

  Future<void> updateBill({
    required String billNumber,
    required String vendorName,
    required DateTime billDate,
    required String billImagePath,
    required double billAmount,
    required String approvalStatus,
    required String remarks,
    required List<ItemEntry> receivedItems,
  }) async {
    try {
      await _billsCollection.doc(billNumber).update({
        'vendorName': vendorName,
        'billNumber': billNumber,
        'billDate': billDate,
        'billImagePath': billImagePath,
        'billAmount': billAmount,
        'approvalStatus': approvalStatus,
        'remarks': remarks,
        'receivedItems': receivedItems
            .map((item) => {
                  'itemName': item.itemName,
                  'ratePerUnit': item.ratePerUnit,
                  'quantityReceived': item.quantityReceived,
                })
            .toList(),
      });
      await fetchBills(); // Refresh the list after updating a bill
    } catch (e) {
      print('Error updating bill: $e');
    }
  }

  Future<void> addBill({
    required String vendorName,
    required String billNumber,
    required DateTime billDate,
    required String billImagePath,
    required double billAmount,
    required String approvalStatus,
    required String remarks,
    required List<ItemEntry> receivedItems,
  }) async {
    try {
      await _billsCollection.doc(billNumber).set({
        'vendorName': vendorName,
        'billNumber': billNumber,
        'billDate': billDate,
        'billImagePath': billImagePath,
        'billAmount': billAmount,
        'approvalStatus': approvalStatus,
        'remarks': remarks,
        'receivedItems': receivedItems
            .map((item) => {
                  'itemName': item.itemName,
                  'ratePerUnit': item.ratePerUnit,
                  'quantityReceived': item.quantityReceived,
                })
            .toList(),
        'month': billDate.month.toString(),
        'date': billDate.day.toString(),
      });
      await fetchBills(); // Refresh the list after adding a new bill
    } catch (e) {
      print('Error adding bill: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBillsForVoucher(String selectedMonth,
      String selectedVendor, String selectedDateRange) async {
    List<Map<String, dynamic>> bills = [];

    try {
      int currentYear = DateTime.now().year;
      DateTime firstDayOfCurrentMonth =
          DateTime(currentYear, int.parse(selectedMonth), 1);
      DateTime lastDayOfCurrentMonth =
          DateTime(currentYear, int.parse(selectedMonth) + 1, 0);
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('billsOfPurchase')
              .where('month', isEqualTo: selectedMonth)
              .where('vendorName', isEqualTo: selectedVendor)
              .where('approvalStatus', isEqualTo: 'approved')
              .get();

      //  convert each one to a Map

      querySnapshot.docs.where((element) {
        return element['billDate'].toDate() != null &&
            element['billDate'].toDate().isAfter(firstDayOfCurrentMonth) &&
            element['billDate'].toDate().isBefore(lastDayOfCurrentMonth);
      }).forEach((DocumentSnapshot<Map<String, dynamic>> document) {
        Map<String, dynamic> billData = document.data()!;

        bills.add(billData);
      });

      List<Map<String, dynamic>> resultBills = bills.where((element) {
        if (selectedDateRange == '0') {
          return int.parse(element['date']) <= 15;
        } else {
          return int.parse(element['date']) > 15;
        }
      }).toList();
      resultBills.sort(
          (a, b) => a['billDate'].toDate().compareTo(b['billDate'].toDate()));
      return resultBills;
    } catch (e) {
      print("Error fetching bills: $e");
      return bills;
    }
  }
}
