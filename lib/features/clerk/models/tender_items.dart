class TenderItem {
  final String itemName;
  final double quantity;
  final String units;
  final String remarks;
  final String brand;

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

  Map<String, dynamic> toJson() => toMap();

  factory TenderItem.fromMap(Map<String, dynamic> map) {
    return TenderItem(
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      units: map['units'] ?? '',
      remarks: map['remarks'] ?? '',
      brand: map['brand'] ?? '',
    );
  }
}
