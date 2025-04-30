import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String billNumber;
  final DateTime billDate;
  final double billAmount;
  final String vendorId;
  final String vendorName;
  final String hostelId;
  final bool isIncludedInVoucher;
  final String? voucherId;

  Bill({
    required this.id,
    required this.billNumber,
    required this.billDate,
    required this.billAmount,
    required this.vendorId,
    required this.vendorName,
    required this.hostelId,
    this.isIncludedInVoucher = false,
    this.voucherId,
  });

  factory Bill.fromMap(Map<String, dynamic> data, String docId) {
    return Bill(
      id: docId,
      billNumber: data['billNumber'] ?? '',
      billDate: (data['billDate'] as Timestamp).toDate(),
      billAmount: (data['billAmount'] ?? 0.0).toDouble(),
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      hostelId: data['hostelId'] ?? '',
      isIncludedInVoucher: data['isIncludedInVoucher'] ?? false,
      voucherId: data['voucherId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billNumber': billNumber,
      'billDate': Timestamp.fromDate(billDate),
      'billAmount': billAmount,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'hostelId': hostelId,
      'isIncludedInVoucher': isIncludedInVoucher,
      'voucherId': voucherId,
    };
  }

  Bill copyWith({
    String? id,
    String? billNumber,
    DateTime? billDate,
    double? billAmount,
    String? vendorId,
    String? vendorName,
    String? hostelId,
    bool? isIncludedInVoucher,
    String? voucherId,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      billAmount: billAmount ?? this.billAmount,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      hostelId: hostelId ?? this.hostelId,
      isIncludedInVoucher: isIncludedInVoucher ?? this.isIncludedInVoucher,
      voucherId: voucherId ?? this.voucherId,
    );
  }
}
