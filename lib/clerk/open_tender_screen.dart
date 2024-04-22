import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../providers/tender_provider.dart'; // Import your tender provider

class OpenTenderScreen extends StatefulWidget {
  @override
  _OpenTenderScreenState createState() => _OpenTenderScreenState();
}

class _OpenTenderScreenState extends State<OpenTenderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  DateTime _deadline = DateTime.now();
  DateTime _openingDate = DateTime.now();
  String _filePath = '';
  final List<TenderItem> _tenderItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Tender'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tender Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMaxHeight: 70,
                  showBottomBorder: true,
                  columns: const [
                    DataColumn(label: Text('Sr No')),
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Remarks')),
                    DataColumn(label: Text('Brand')),
                  ],
                  rows: [
                    for (int i = 0; i < _tenderItems.length; i++)
                      DataRow(cells: [
                        DataCell(SizedBox(child: Text('${i + 1}'))),
                        DataCell(Text(_tenderItems[i].itemName)),
                        DataCell(Text(
                            '${_tenderItems[i].quantity} ${_tenderItems[i].units}')),
                        DataCell(SizedBox(
                          width: 100,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remarks'),
                                  content: SingleChildScrollView(
                                    child: Text(_tenderItems[i].remarks),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(_tenderItems[i].remarks,
                                overflow: TextOverflow.ellipsis, maxLines: 2),
                          ),
                        )),
                        DataCell(Text(_tenderItems[i].brand)),
                      ]),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Add Item'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Deadline for Filing Bids:'),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(_formatDate(_deadline))),
                  IconButton(
                    onPressed: () => _selectDeadline(context),
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Date of Opening of Bids:'),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(_formatDate(_openingDate))),
                  IconButton(
                    onPressed: () => _selectOpeningDate(context),
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Implement file upload functionality
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf']);
                        if (result != null) {
                          setState(() {
                            _filePath = result.files.single.path!;
                          });
                        }
                      },
                      child: Text(
                          _filePath == '' ? 'Upload File' : 'File Selected'),
                    ),
                  ),
                  if (_filePath != '')
                    TextButton(
                      onPressed: () => _viewFile(context),
                      child: const Text('View File'),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitTender,
                child: const Text('Submit Tender'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewFile(BuildContext context) {
    OpenFilex.open(_filePath);
  }

  void _addItem() {
    showDialog(context: context, builder: _buildAddItemDialog);
  }

  Widget _buildAddItemDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Item Name'),
              controller: _itemNameController,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              controller: _quantityController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Units'),
              controller: _unitsController,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Remarks'),
              controller: _remarksController,
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Brand'),
              controller: _brandController,
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                if (_itemNameController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _unitsController.text.isEmpty ||
                    _remarksController.text.isEmpty ||
                    _brandController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all the fields'),
                    ),
                  );
                  return;
                }
                _tenderItems.add(TenderItem(
                  itemName: _itemNameController.text,
                  quantity: double.parse(_quantityController.text),
                  units: _unitsController.text,
                  remarks: _remarksController.text,
                  brand: _brandController.text,
                ));
                Navigator.pop(context);
                _itemNameController.clear();
                _quantityController.clear();
                _unitsController.clear();
                _remarksController.clear();
                _brandController.clear();
                setState(() {});
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
        if (_openingDate.isBefore(_deadline)) {
          _openingDate = _deadline;
        }
      });
    }
  }

  void _selectOpeningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _openingDate,
      firstDate: _deadline,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _openingDate) {
      setState(() {
        _openingDate = picked;
      });
    }
  }

  void _submitTender() async {
    if (_filePath == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a file'),
        ),
      );
      return;
    }
    if(_tenderItems.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
        ),
      );
      return;
    }
    String fileUrl = '';

    if (_filePath == '') {
      print('No file uploaded');
    } else {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('tenders')
          .child(_titleController.text);
      await ref.putFile(File(_filePath));
      fileUrl = await ref.getDownloadURL();
      print('File uploaded to $fileUrl');
    }
    if (_formKey.currentState!.validate()) {
      Tender tender = Tender(
        tenderId: 'T${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        tenderItems: _tenderItems,
        deadline: _deadline,
        openingDate: _openingDate,
        fileUrl: fileUrl, // Implement file upload functionality
        bids: [],
      );
      // Save tender to provider or database


      Provider.of<TenderProvider>(context, listen: false).addTender(tender);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tender submitted successfully'),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
