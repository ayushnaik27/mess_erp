// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class Vendor {
//   final String id;
//   final String companyName;
//   final String name;
//   final String phoneNumber;
//   final String gstin;
//   final String emailId;
//   final String address;
//   final String state;
//   final String postalCode;
//   final String panNumber;
//   final String establishmentYear;
//   final String type;
//   String password;

//   Vendor({
//     required this.id,
//     required this.companyName,
//     required this.name,
//     required this.phoneNumber,
//     required this.gstin,
//     required this.emailId,
//     required this.address,
//     required this.state,
//     required this.postalCode,
//     required this.panNumber,
//     required this.establishmentYear,
//     required this.type,
//     this.password = '',
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'companyName': companyName,
//       'name': name,
//       'phoneNumber': phoneNumber,
//       'gstin': gstin,
//       'emailId': emailId,
//       'address': address,
//       'state': state,
//       'postalCode': postalCode,
//       'panNumber': panNumber,
//       'establishmentYear': establishmentYear,
//       'type': type,
//       'password': password,
//     };
//   }

//   static Vendor fromMap(String id, Map<String, dynamic> data) {
//     return Vendor(
//       id: id,
//       companyName: data['companyName'],
//       name: data['name'],
//       phoneNumber: data['phoneNumber'],
//       gstin: data['gstin'],
//       emailId: data['emailId'],
//       address: data['address'],
//       state: data['state'],
//       postalCode: data['postalCode'],
//       panNumber: data['panNumber'],
//       establishmentYear: data['establishmentYear'],
//       type: data['type'],
//       password: data['password'],
//     );
//   }
// }

// class VendorProvider with ChangeNotifier {
//   List<Vendor> _vendors = [];

//   List<Vendor> get vendors => _vendors;

//   Vendor _currentVendor = Vendor(
//     id: '',
//     companyName: '',
//     name: '',
//     phoneNumber: '',
//     gstin: '',
//     emailId: '',
//     address: '',
//     state: '',
//     postalCode: '',
//     panNumber: '',
//     establishmentYear: '',
//     type: '',
//   );

//   Vendor get currentVendor => _currentVendor;

//   String _currentVendorId = '';

//   String get currentVendorId => _currentVendorId;

//   void addVendor(Vendor vendor) {
//     _vendors.add(vendor);
//     notifyListeners();
//   }

//   Future<void> setCurrentVendor(String vendorId) {
//     _currentVendorId = vendorId;

//     FirebaseFirestore.instance
//         .collection('vendors')
//         .doc(vendorId)
//         .get()
//         .then((doc) {
//       _currentVendor = Vendor.fromMap(doc.id, doc.data()!);
//     });

//     notifyListeners();
//     return Future.value();
//   }

//   Future<Vendor> getVendorById(String vendorId) async {
//     await FirebaseFirestore.instance
//         .collection('vendors')
//         .doc(vendorId)
//         .get()
//         .then((doc) {
//       return Vendor.fromMap(doc.id, doc.data()!);
//     });
//     return Vendor(
//       id: '',
//       companyName: '',
//       name: '',
//       phoneNumber: '',
//       gstin: '',
//       emailId: '',
//       address: '',
//       state: '',
//       postalCode: '',
//       panNumber: '',
//       establishmentYear: '',
//       type: '',
//     );
//   }

//   Future<List<Vendor>> fetchAndSetVendors() async {
//     final QuerySnapshot<Map<String, dynamic>> vendorSnapshot =
//         await FirebaseFirestore.instance.collection('vendors').get();
//     _vendors.clear();
//     vendorSnapshot.docs.forEach((doc) {
//       _vendors.add(Vendor(
//         id: doc.id,
//         companyName: doc['companyName'],
//         name: doc['name'],
//         phoneNumber: doc['phoneNumber'],
//         gstin: doc['gstin'],
//         emailId: doc['emailId'],
//         address: doc['address'],
//         state: doc['state'],
//         postalCode: doc['postalCode'],
//         panNumber: doc['panNumber'],
//         establishmentYear: doc['establishmentYear'],
//         type: doc['type'],
//       ));
//     });
//     notifyListeners();
//     return _vendors;
//   }

//   List<String> getVendorNames() {
//     return _vendors.map((vendor) => vendor.companyName).toList();
//   }

  

//   void removeVendor(String vendorId) {
//     _vendors.removeWhere((vendor) => vendor.id == vendorId);
//     notifyListeners();
//   }
// }
