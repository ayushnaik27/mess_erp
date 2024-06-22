import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StockProvider extends ChangeNotifier {
  final CollectionReference _stockCollection =
      FirebaseFirestore.instance.collection('stock');

  Future<void> addStock({
    required String itemName,
    required DateTime transactionDate,
    required String vendor,
    required int receivedQuantity,
    required int issuedQuantity,
    required double balance,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _stockCollection.orderBy('transactionDate',descending: false).get() as QuerySnapshot<Map<String, dynamic>>;

      if (snapshot.docs.isNotEmpty) {
        print('Document exists!');

        final double previousBalance = snapshot.docs.last['balance'];

        if(snapshot.docs.where((element) => element == itemName).isEmpty){
          print('Item does not exist');
          await _stockCollection.doc().set({
            'itemName': itemName,
            'transactionDate': transactionDate,
            'date': {
              'day': transactionDate.day,
              'month': transactionDate.month,
              'year': transactionDate.year,
            },
            'vendor': vendor,
            'receivedQuantity': receivedQuantity,
            'issuedQuantity': issuedQuantity,
            'balance': balance + previousBalance,
            'quantity': receivedQuantity,
          });
          return;
        }
        
        final int previousQuantity = snapshot.docs.lastWhere(
            (element) => element['itemName'] == itemName)['quantity'] as int;
        print('Previous balance: $previousBalance');
        await _stockCollection.doc().set({
          'itemName': itemName,
          'transactionDate': transactionDate,
          'date': {
            'day': transactionDate.day,
            'month': transactionDate.month,
            'year': transactionDate.year,
          },
          'vendor': vendor,
          'receivedQuantity': receivedQuantity,
          'issuedQuantity': issuedQuantity,
          'balance': balance + previousBalance,
          'quantity': previousQuantity + receivedQuantity,
        });
      } else {
        // Document does not exist
        print('Document does not exist!');
        await _stockCollection.doc().set({
          'itemName': itemName,
          'transactionDate': transactionDate,
          'date': {
            'day': transactionDate.day,
            'month': transactionDate.month,
            'year': transactionDate.year,
          },
          'vendor': vendor,
          'receivedQuantity': receivedQuantity,
          'issuedQuantity': issuedQuantity,
          'balance': balance,
          'quantity': receivedQuantity,
        });
      }
    } catch (e) {
      print('Error adding stock: $e');
      
    }
  }

  Future<int> fetchStockBalance(String itemName) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _stockCollection
              .orderBy('transactionDate', descending: false)
              .get() as QuerySnapshot<Map<String, dynamic>>;
      if (snapshot.docs.isNotEmpty) {
        print('I am here');
        return snapshot.docs.lastWhere(
            (element) => element['itemName'] == itemName)['quantity'];
      }
      return 0;
    } catch (e) {
      print('Error fetching stock: $e');
      return 0;
    }
  }

  Future<double> fetchBalance() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _stockCollection
              .orderBy('transactionDate', descending: false)
              .get() as QuerySnapshot<Map<String, dynamic>>;
      return double.parse(snapshot.docs.last['balance'].toString());
    } catch (e) {
      print('Error fetching stock: $e');
      return 0;
    }
  }

  Future<void> issueStock(
      String itemName, int quantityToIssue, double amount) async {
        log('Issuing stock');
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _stockCollection
          .orderBy('transactionDate', descending: false)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (snapshot.docs.isNotEmpty) {
        // Document with the specified itemName exists
        print('Document exists!');
        // You can access the document data using snapshot.docs[0].data() or iterate through them
        final double previousBalance = double.parse(snapshot.docs.last['balance'].toString());

        int previousQuantity = snapshot.docs.lastWhere((element) =>
            element['itemName'] == itemName)['quantity'] as int;
        log('Previous quantity: $previousQuantity');
        final DateTime transactionDate = DateTime.now();
        print('Previous balance: $previousBalance');
        await _stockCollection.doc().set({
          'itemName': itemName,
          'issuedQuantity': quantityToIssue,
          'balance': previousBalance - amount,
          'transactionDate': transactionDate,
          'date': {
            'day': transactionDate.day,
            'month': transactionDate.month,
            'year': transactionDate.year,
          },
          'quantity': previousQuantity - quantityToIssue,
          'receivedQuantity': 0,
        });
      } else {
        // Document does not exist
        print('Document does not exist!');
        await _stockCollection.add({
          'itemName': itemName,
          'issuedQuantity': quantityToIssue,
          'balance': -amount,
          'quanitity': -quantityToIssue,
        });
      }
    } catch (e) {
      print('Error adding stock: $e');
    }
  }
}
