class Vendor {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String hostelId;

  Vendor({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.hostelId,
  });

  factory Vendor.fromMap(Map<String, dynamic> data, String docId) {
    return Vendor(
      id: docId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      hostelId: data['hostelId'] ?? '',
    );
  }
}
