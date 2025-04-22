import 'package:cloud_firestore/cloud_firestore.dart';

import 'bid.dart';
import 'tender_items.dart';

class Tender {
  final String tenderId;
  final String title;
  final List<TenderItem> tenderItems;
  final DateTime deadline;
  final DateTime openingDate;
  final String fileUrl;
  final List<Bid> bids;
  final DateTime? createdAt;
  final String? status;

  Tender({
    required this.tenderId,
    required this.title,
    required this.tenderItems,
    required this.deadline,
    required this.openingDate,
    required this.fileUrl,
    required this.bids,
    this.createdAt,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'tenderId': tenderId,
      'title': title,
      'tenderItems': tenderItems.map((item) => item.toMap()).toList(),
      'deadline': deadline,
      'openingDate': openingDate,
      'fileUrl': fileUrl,
      'bids': bids.map((bid) => bid.toMap()).toList(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'status': status ?? 'active',
    };
  }

  factory Tender.fromMap(Map<String, dynamic> map) {
    return Tender(
      tenderId: map['tenderId'] ?? '',
      title: map['title'] ?? '',
      tenderItems: List<TenderItem>.from(
        (map['tenderItems'] as List? ?? []).map(
          (item) => TenderItem.fromMap(item),
        ),
      ),
      deadline: (map['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      openingDate:
          (map['openingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileUrl: map['fileUrl'] ?? '',
      bids: List<Bid>.from(
        (map['bids'] as List? ?? []).map(
          (bid) => Bid.fromMap(bid),
        ),
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      status: map['status'],
    );
  }

  Tender copyWith({
    String? tenderId,
    String? title,
    List<TenderItem>? tenderItems,
    DateTime? deadline,
    DateTime? openingDate,
    String? fileUrl,
    List<Bid>? bids,
    DateTime? createdAt,
    String? status,
  }) {
    return Tender(
      tenderId: tenderId ?? this.tenderId,
      title: title ?? this.title,
      tenderItems: tenderItems ?? this.tenderItems,
      deadline: deadline ?? this.deadline,
      openingDate: openingDate ?? this.openingDate,
      fileUrl: fileUrl ?? this.fileUrl,
      bids: bids ?? this.bids,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
