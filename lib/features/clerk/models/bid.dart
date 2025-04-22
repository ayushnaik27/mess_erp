import 'package:cloud_firestore/cloud_firestore.dart';

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
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      itemPrices: (map['itemPrices'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value ?? 0).toDouble()),
          ) ??
          {},
    );
  }
}
