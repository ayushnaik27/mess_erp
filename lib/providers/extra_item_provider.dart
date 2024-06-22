import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExtraItem {
  String? id;
  String name;
  double price;

  ExtraItem({required this.name, required this.price, this.id});
}

class ExtraItemRequest {
  final String id;
  final String rollNumber;
  final String itemName;
  final int quantity;
  double amount;
  DateTime timestamp;

  ExtraItemRequest(
      {required this.rollNumber,
      required this.itemName,
      required this.quantity,
      required this.id,
      this.amount = 0,
      required this.timestamp});
}

class ExtraItemsProvider with ChangeNotifier {
  final List<ExtraItem> _extraItems = [];

  List<ExtraItem> get extraItems {
    return [..._extraItems];
  }

  Future<List<ExtraItem>> fetchExtraItems() async {
    final QuerySnapshot<Map<String, dynamic>> extraItemsSnapshot =
        await FirebaseFirestore.instance.collection('extra_items').get();
    _extraItems.clear();
    extraItemsSnapshot.docs.forEach((doc) {
      _extraItems.add(ExtraItem(
          id: doc.id,
          name: doc['name'],
          price: double.parse(doc['price'].toString())));
    });
    notifyListeners();
    return _extraItems;
  }

  Future<void> addExtraItem(String itemName, double itemPrice) async {
    if (itemName.isNotEmpty && itemPrice > 0) {
      _extraItems.add(ExtraItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: itemName,
          price: itemPrice));

      await FirebaseFirestore.instance.collection('extra_items').add({
        'name': itemName,
        'price': itemPrice,
      });
    }
  }

  Future<void> editExtraItem(
      String itemId, String itemName, double itemPrice) async {
    if (itemName.isNotEmpty && itemPrice > 0) {
      final int index =
          _extraItems.indexWhere((ExtraItem item) => item.id == itemId);
      _extraItems[index] =
          ExtraItem(id: itemId, name: itemName, price: itemPrice);
      await FirebaseFirestore.instance
          .collection('extra_items')
          .doc(itemId)
          .update({
        'name': itemName,
        'price': itemPrice,
      });
    }
  }

  Future<void> deleteExtraItem(String itemId) async {
    _extraItems.removeWhere((ExtraItem item) => item.id == itemId);
    await FirebaseFirestore.instance
        .collection('extra_items')
        .doc(itemId)
        .delete();
  }

  Future<void> addExtraItemRequest(
      {required String rollNumber,
      required String itemName,
      required int quantity,
      required double amount}) async {
    await FirebaseFirestore.instance.collection('extra_item_requests').add({
      'rollNumber': rollNumber,
      'itemName': itemName,
      'quantity': quantity,
      'amount': amount,
      'timestamp': DateTime.now(),
    });
  }

  Stream<List<ExtraItemRequest>> fetchExtraItemRequests() {
    return FirebaseFirestore.instance
        .collection('extra_item_requests')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExtraItemRequest(
          rollNumber: doc['rollNumber'],
          itemName: doc['itemName'],
          quantity: doc['quantity'],
          id: doc.id,
          amount: double.parse(doc['amount'].toString()),
          timestamp: doc['timestamp'].toDate(),
        );
      }).toList();
    });
  }

  Future<void> deleteExtraItemRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('extra_item_requests')
        .doc(requestId)
        .delete();
  }

  Future<void> addBillForStudent(
      String rollNumber, DateTime date, String itemName, double amount) async {
    try {
      CollectionReference studentsBillCollection = FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('bill');

      String docId = DateFormat('dd-MM-yyyy').format(date);

      studentsBillCollection.doc(docId).set({
        'date': DateTime.now(),
        'year': DateTime.now().year.toString(),
        'month': DateTime.now().month.toString(),
        'items': FieldValue.arrayUnion([
          {
            'item': itemName,
            'amount': amount,
          }
        ]),
        // 'item': itemName,
        // 'quantity': quantity,
        // 'amount': amount,
      }, SetOptions(merge: true));

      FirebaseFirestore.instance
          .collection('extra_amount')
          .doc('extra_amount')
          .set({
        'amount': FieldValue.increment(amount),
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> approveExtraItemRequest(
      {required String requestId,
      required String rollNumber,
      required String itemName,
      required int quantity,
      required double amount}) async {
    // Logic to delete the request and reflect the entry in the student's account
    // (Replace 'requestsCollection' and 'studentsAccountCollection' with your actual collection names)

    print(requestId);
    deleteExtraItemRequest(requestId);
    print('done');
    addBillForStudent(rollNumber, DateTime.now(), itemName, amount);
    print('done2');

    // Reflect the entry in the student's account (Update 'studentsAccountCollection' accordingly)
    // ...
    notifyListeners();
  }
}
