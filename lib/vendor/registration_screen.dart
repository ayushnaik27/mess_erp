// import 'package:flutter/material.dart';
// import 'package:mess_erp/vendor/registration_step_two.dart';

// import '../providers/vendor_provider.dart';

// class VendorRegisterScreen extends StatefulWidget {
//   @override
//   _VendorRegisterScreenState createState() => _VendorRegisterScreenState();
// }

// class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
//   String? _selectedVendorType;
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneNoController = TextEditingController();
//   final TextEditingController _optionalPhoneNoController =
//       TextEditingController();
//   final TextEditingController _gstinController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _postalCodeController = TextEditingController();
//   final TextEditingController _panNumberController = TextEditingController();
//   final TextEditingController _establishmentYearController =
//       TextEditingController();

//   final List<String> _vendorTypes = [
//     'Fruits/Vegetables',
//     'Milk and its products',
//     'Bakery (Bread, Vada Pav)',
//     'Eggs',
//     'Dry Ration',
//     'Other (Please specify)',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vendor Registration'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _companyNameController,
//                 decoration: const InputDecoration(
//                     labelText: 'Company Name / Licence Holder'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter company name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _phoneNoController,
//                 decoration: const InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter phone number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _optionalPhoneNoController,
//                 decoration:
//                     const InputDecoration(labelText: 'Optional Phone Number'),
//               ),
//               TextFormField(
//                 controller: _gstinController,
//                 decoration: const InputDecoration(labelText: 'GSTIN'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter GSTIN';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: 'Address'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter address';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _stateController,
//                 decoration: const InputDecoration(labelText: 'State'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter state';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _postalCodeController,
//                 decoration: const InputDecoration(labelText: 'Postal Code'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter postal code';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _panNumberController,
//                 decoration: const InputDecoration(labelText: 'PAN Number'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter PAN number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _establishmentYearController,
//                 decoration:
//                     const InputDecoration(labelText: 'Year of Establishment'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter year of establishment';
//                   }
//                   return null;
//                 },
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedVendorType,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedVendorType = newValue;
//                   });
//                 },
//                 items: _vendorTypes.map((type) {
//                   return DropdownMenuItem(
//                     value: type,
//                     child: Text(type),
//                   );
//                 }).toList(),
//                 decoration: const InputDecoration(labelText: 'Type of Vendor'),
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // All fields are valid, proceed to next step
//                     // For example, navigate to the next page to set password

//                     // Create a Vendor object and pass it to the next screen
//                     Vendor vendor = Vendor(
//                       companyName: _companyNameController.text,
//                       name: _nameController.text,
//                       phoneNumber: _phoneNoController.text,
//                       gstin: _gstinController.text,
//                       emailId: _emailController.text,
//                       address: _addressController.text,
//                       state: _stateController.text,
//                       postalCode: _postalCodeController.text,
//                       panNumber: _panNumberController.text,
//                       establishmentYear: _establishmentYearController.text,
//                       type: _selectedVendorType!, id: 'V${DateTime.now().microsecond}',
//                     );
                    

//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return VendorSetPassword(vendor: vendor);
//                     }));
//                   }
//                 },
//                 child: const Text('Next'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
