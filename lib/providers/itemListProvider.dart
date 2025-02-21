import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemListProvider with ChangeNotifier {
  List<String> _items = [];

  List<String> get items => _items;

  List<Map<String, dynamic>> _itemsWithRate = [];

  List<Map<String, dynamic>> get itemsWithRate => _itemsWithRate;

  Future<List<String>> fetchAndSetItems() async {
    try {
      _items.clear();
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('itemsList').get();
      _items = snapshot.docs
          .toList()
          .map((DocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.data()!['name'] as String)
          .toList();
      _items.sort();
      notifyListeners();
      return _items;
    } catch (e) {
      print('Error fetching items: $e');
      rethrow;
    }
  }

  Future<void> addItem(String item, double ratePerUnit) async {
    await FirebaseFirestore.instance
        .collection('itemsList')
        .add({'name': item, 'ratePerUnit': ratePerUnit});
    notifyListeners();
  }

  Future<void> editItem(String item, double ratePerUnit) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('itemsList')
        .where('name', isEqualTo: item)
        .get();
    final String docId = snapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('itemsList')
        .doc(docId)
        .update({'ratePerUnit': ratePerUnit});
    notifyListeners();
  }

  List<String> getItems() {
    _items.sort();

    return _items;
  }

  Future<void> fetchItemsWithRate() async {
    try {
      _itemsWithRate.clear();
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('itemsList').get();
      _itemsWithRate = snapshot.docs
          .toList()
          .map((DocumentSnapshot<Map<String, dynamic>> doc) => {
                'name': doc.data()!['name'] as String,
                'ratePerUnit': doc.data()!['ratePerUnit'] as double,
              })
          .toList();
      _itemsWithRate.sort((a, b) => a['name'].compareTo(b['name']));
      notifyListeners();
    } catch (e) {
      print('Error fetching items with rate: $e');
      rethrow;
    }
  }
}
