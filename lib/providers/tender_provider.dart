import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Tender {
  String tenderId;
  String title;
  List<TenderItem> tenderItems;
  DateTime deadline;
  DateTime openingDate;
  String fileUrl;
  List<Bid> bids;

  Tender({
    required this.tenderId,
    required this.title,
    required this.tenderItems,
    required this.deadline,
    required this.openingDate,
    required this.fileUrl,
    required this.bids,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'tenderItems': tenderItems.map((item) => item.toMap()).toList(),
      'deadline': deadline,
      'openingDate': openingDate,
      'fileUrl': fileUrl,
      'tenderId': tenderId,
      'bids': bids.map((bid) => bid.toMap()).toList(),
    };
  }
}

class TenderItem {
  String itemName;
  double quantity;
  String units;
  String remarks;
  String brand;

  TenderItem({
    required this.itemName,
    required this.quantity,
    required this.units,
    required this.remarks,
    required this.brand,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'units': units,
      'remarks': remarks,
      'brand': brand,
    };
  }
}

class Bid {
  final String vendorId;
  final String vendorName;
  final double totalPrice;
  final Map<String, double> itemPrices; // Map of item name to price

  Bid({
    required this.vendorId,
    required this.vendorName,
    required this.totalPrice,
    required this.itemPrices,
  });

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'totalPrice': totalPrice,
      'itemPrices': itemPrices,
    };
  }
}

class TenderProvider extends ChangeNotifier {
  List<Tender> _tenders = [];
  List<Tender> _activeTenders = [];

  List<Tender> get tenders => _tenders;
  List<Tender> get activeTenders => _activeTenders;

  Future<void> fetchAndSetTenders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('tenders').get();
    _tenders = snapshot.docs.map((doc) {
      final data = doc.data();
      return Tender(
        tenderId: data['tenderId'],
        title: data['title'],
        tenderItems: (data['tenderItems'] as List).map((item) {
          return TenderItem(
            itemName: item['itemName'],
            quantity: item['quantity'],
            units: item['units'],
            remarks: item['remarks'],
            brand: item['brand'],
          );
        }).toList(),
        deadline: data['deadline'].toDate(),
        openingDate: data['openingDate'].toDate(),
        fileUrl: data['fileUrl'],
        bids: (data['bids'] as List).map((bid) {
          return Bid(
            vendorId: bid['vendorId'],
            vendorName: bid['vendorName'],
            totalPrice: bid['totalPrice'].toDouble(),
            itemPrices:
                (bid['itemPrices'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, value.toDouble());
            }),
          );
        }).toList(),
      );
    }).toList();
    notifyListeners();
  }

  Tender findById(String id) {
    return _tenders.firstWhere((tender) => tender.title == id);
  }

  Future<void> addTender(Tender tender) async {
    await FirebaseFirestore.instance
        .collection('tenders')
        .doc(tender.tenderId)
        .set(tender.toMap());
  }

  Future<List<Tender>> fetchAllTenders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('tenders').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Tender(
        tenderId: data['tenderId'],
        title: data['title'],
        tenderItems: (data['tenderItems'] as List).map((item) {
          return TenderItem(
            itemName: item['itemName'],
            quantity: item['quantity'],
            units: item['units'],
            remarks: item['remarks'],
            brand: item['brand'],
          );
        }).toList(),
        deadline: data['deadline'].toDate(),
        openingDate: data['openingDate'].toDate(),
        fileUrl: data['fileUrl'],
        bids: (data['bids'] as List).map((bid) {
          return Bid(
            vendorId: bid['vendorId'],
            vendorName: bid['vendorName'],
            totalPrice: bid['totalPrice'].toDouble(),
            itemPrices:
                (bid['itemPrices'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, value.toDouble());
            }),
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> fetchAndSetActiveTenders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tenders')
        .where('deadline', isGreaterThanOrEqualTo: DateTime.now())
        .get();
    _activeTenders = snapshot.docs.map((doc) {
      final data = doc.data();
      return Tender(
        tenderId: data['tenderId'],
        title: data['title'],
        tenderItems: (data['tenderItems'] as List).map((item) {
          return TenderItem(
            itemName: item['itemName'],
            quantity: item['quantity'],
            units: item['units'],
            remarks: item['remarks'],
            brand: item['brand'],
          );
        }).toList(),
        deadline: data['deadline'].toDate(),
        openingDate: data['openingDate'].toDate(),
        fileUrl: data['fileUrl'],
        bids: data['bids'] == null
            ? []
            : (data['bids'] as List).map((bid) {
                return Bid(
                  vendorId: bid['vendorId'],
                  vendorName: bid['vendorName'],
                  totalPrice: bid['totalPrice'].toDouble(),
                  itemPrices: (bid['itemPrices'] as Map<String, dynamic>)
                      .map((key, value) {
                    return MapEntry(key, value.toDouble());
                  }),
                );
              }).toList(),
      );
    }).toList();
    notifyListeners();
  }

  Future<void> submitBid(String tenderId, Bid bid) async {
    print('Tender ID: $tenderId');
    await FirebaseFirestore.instance
        .collection('tenders')
        .doc(tenderId)
        .update({
      'bids': FieldValue.arrayUnion([bid.toMap()]),
    });
  }
  // Implement other methods as needed, such as fetching active tenders from a database
}
