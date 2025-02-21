import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorNameProvider with ChangeNotifier {
  List<String> _vendorNames = [];

  List<String> get vendorNames => _vendorNames;

  Future<List<String>> fetchAndSetVendorNames() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('vendorList').get();
      _vendorNames = snapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.data()!['name'] as String)
          .toList();
      notifyListeners();
      return _vendorNames;
    } catch (e) {
      print('Error fetching vendor names: $e');
      rethrow;
    }
  }

  List<String> getVendorNames() {
    return _vendorNames;
  }
}
