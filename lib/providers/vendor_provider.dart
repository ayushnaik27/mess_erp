import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Vendor {
  final String id;
  final String type;
  final String name;
  final String gstin;
  final String mobileNo;
  final String address;
  final String emailId;

  Vendor({
    required this.id,
    required this.type,
    required this.name,
    required this.gstin,
    required this.mobileNo,
    required this.address,
    required this.emailId,
  });
}

class VendorProvider with ChangeNotifier {
  List<Vendor> _vendors = [];

  List<Vendor> get vendors => _vendors;

  void addVendor(Vendor vendor) {
    _vendors.add(vendor);
    notifyListeners();
  }

  Future<List<Vendor>> fetchAndSetVendors() async {
    final QuerySnapshot<Map<String, dynamic>> vendorSnapshot =
        await FirebaseFirestore.instance.collection('vendors').get();
    _vendors.clear();
    vendorSnapshot.docs.forEach((doc) {
      _vendors.add(Vendor(
        id: doc.id,
        type: doc['type'],
        name: doc['name'],
        gstin: doc['gstin'],
        mobileNo: doc['mobileNo'],
        address: doc['address'],
        emailId: doc['emailId'],
      ));
    });
    notifyListeners();
    return _vendors;
  }

  List<String> getVendorNames() {
    return _vendors.map((vendor) => vendor.name).toList();
  }

  void removeVendor(String vendorId) {
    _vendors.removeWhere((vendor) => vendor.id == vendorId);
    notifyListeners();
  }
}
