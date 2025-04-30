class ExtraItem {
  final String name;
  final double price;
  final String? id;

  ExtraItem({
    required this.name,
    required this.price,
    this.id,
  });

  factory ExtraItem.fromMap(Map<String, dynamic> data, String id) {
    return ExtraItem(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}
