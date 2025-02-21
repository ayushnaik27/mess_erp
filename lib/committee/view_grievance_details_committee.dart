import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/grievance_provider.dart';
import '../student/grievance_detail_screen.dart';

class GrievanceDetailsForCommitteeScreen extends StatefulWidget {
  final Grievance grievance;
  final String userType;

  const GrievanceDetailsForCommitteeScreen(
      {Key? key, required this.grievance, required this.userType})
      : super(key: key);

  @override
  State<GrievanceDetailsForCommitteeScreen> createState() =>
      _GrievanceDetailsForCommitteeScreenState();
}

class _GrievanceDetailsForCommitteeScreenState
    extends State<GrievanceDetailsForCommitteeScreen> {
  List<String> commonRemarks = [
    'Okay, we will look into this.',
    'We will get back to you soon.',
    'Your issue has been resolved.',
    'Forwarded to the committee for further action.',
  ];

  String remarks = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grievance.grievanceTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filed on:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                      ' ${DateFormat.yMMMMd().format(widget.grievance.dateOfFiling)}')
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filed by:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(widget.grievance.studentRollNo),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.grievance.status,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(widget.grievance.grievanceDesc),
              const SizedBox(height: 32.0),
              if (widget.grievance.fileUpload.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    // Implement file download functionality
                    final response = await http.get(
                      Uri.parse(widget.grievance.fileUpload),
                    );
                    final bytes = response.bodyBytes;

                    final tempDir = await getTemporaryDirectory();
                    final tempDocumentPath =
                        '${tempDir.path}/${widget.grievance.grievanceId}.pdf';

                    await File(tempDocumentPath).writeAsBytes(bytes);
                    OpenFilex.open(tempDocumentPath);
                    // Use the fileUpload field of the grievance object
                  },
                  child: const Text('View Supporting Document'),
                ),
              const SizedBox(height: 16.0),
              HistoryTable(history: widget.grievance.history.reversed.toList()),
              if (widget.grievance.status != 'resolved')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showResolveDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Resolve',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showForwardDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Forward',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showMarkInProgressDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Mark In Process',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResolveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resolve Grievance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.userType == 'committee'
                  ? TextField(
                      onChanged: (value) {
                        remarks = value;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enter Remarks',
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: '',
                          onChanged: (newValue) {
                            remarks = newValue!;
                          },
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Select remarks'),
                            ),
                            for (String str in commonRemarks)
                              DropdownMenuItem(
                                  value: str,
                                  child: Text(
                                    str,
                                    style: const TextStyle(fontSize: 14),
                                  )),
                            if (widget.userType == 'manager')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the clerk for further action.',
                                child: Text(
                                    'Forwarded to the clerk for further action.'),
                              ),
                            if (widget.userType == 'clerk')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the manager for further action.',
                                child: Text(
                                    'Forwarded to the manager for further action.'),
                              )
                          ],
                          decoration: const InputDecoration(
                              labelText: 'Remarks',
                              labelStyle: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (remarks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter remarks'),
                    ),
                  );
                  return;
                } else {
                  await Provider.of<GrievanceProvider>(context, listen: false)
                      .resolveGrievanceWithRemarks(widget.grievance.grievanceId,
                          remarks, widget.userType);
                  // Implement resolve action here
                  // Update grievance status to resolved
                  // Save remarks and other details to history

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary),
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );
  }

  // Implement similar methods for Forward and Mark in Process actions
  void _showForwardDialog() {
    log('User Type: ${widget.userType}');
    // Implement forward dialog
    String? selectedForwardTo = widget.userType == 'manager'
        ? 'Clerk'
        : widget.userType == 'clerk'
            ? 'Manager'
            : 'Committee';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forward Grievance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // TextField(
              //   onChanged: (value) {
              //     remarks = value;
              //   },
              //   maxLines: 3,
              //   decoration: const InputDecoration(
              //     labelText: 'Enter Remarks',
              //   ),
              // ),
              widget.userType == 'committee'
                  ? TextField(
                      onChanged: (value) {
                        remarks = value;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enter Remarks',
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: '',
                          onChanged: (newValue) {
                            remarks = newValue!;
                          },
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Select remarks'),
                            ),
                            for (String str in commonRemarks)
                              DropdownMenuItem(
                                  value: str,
                                  child: Text(
                                    str,
                                    style: const TextStyle(fontSize: 14),
                                  )),
                            if (widget.userType == 'manager')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the clerk for further action.',
                                child: Text(
                                    'Forwarded to the clerk for further action.'),
                              ),
                            if (widget.userType == 'clerk')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the manager for further action.',
                                child: Text(
                                    'Forwarded to the manager for further action.'),
                              )
                          ],
                          decoration: const InputDecoration(
                              labelText: 'Remarks',
                              labelStyle: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: '',
                    onChanged: (newValue) {
                      setState(() {
                        selectedForwardTo = newValue!;
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Select User'),
                      ),
                      if (widget.userType != 'manager')
                        const DropdownMenuItem(
                          value: 'Manager',
                          child:
                              Text('Manager', style: TextStyle(fontSize: 14)),
                        ),
                      if (widget.userType != 'clerk')
                        const DropdownMenuItem(
                          value: 'Clerk',
                          child: Text('Clerk', style: TextStyle(fontSize: 14)),
                        ),
                      if (widget.userType != 'committee')
                        const DropdownMenuItem(
                          value: 'Committee',
                          child:
                              Text('Committee', style: TextStyle(fontSize: 14)),
                        ),
                    ],
                    decoration: const InputDecoration(
                        labelText: 'Forward To',
                        labelStyle: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedForwardTo == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please select a user to forward the grievance to'),
                    ),
                  );
                  return;
                }
                if (remarks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter remarks'),
                    ),
                  );
                  return;
                } else {
                  // Forward grievance logic goes here
                  await Provider.of<GrievanceProvider>(context, listen: false)
                      .forwardGrievanceWithRemarks(widget.grievance.grievanceId,
                          remarks, selectedForwardTo!, widget.userType);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary),
              child: const Text('Forward'),
            ),
          ],
        );
      },
    );
  }

  void _showMarkInProgressDialog() {
    // Implement mark in process dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark in Process'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.userType == 'committee'
                  ? TextField(
                      onChanged: (value) {
                        remarks = value;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Enter Remarks',
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: '',
                          onChanged: (newValue) {
                            remarks = newValue!;
                          },
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Select remarks'),
                            ),
                            for (String str in commonRemarks)
                              DropdownMenuItem(
                                  value: str,
                                  child: Text(
                                    str,
                                    style: const TextStyle(fontSize: 14),
                                  )),
                            if (widget.userType == 'manager')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the clerk for further action.',
                                child: Text(
                                    'Forwarded to the clerk for further action.'),
                              ),
                            if (widget.userType == 'clerk')
                              const DropdownMenuItem(
                                value:
                                    'Forwarded to the manager for further action.',
                                child: Text(
                                    'Forwarded to the manager for further action.'),
                              )
                          ],
                          decoration: const InputDecoration(
                              labelText: 'Remarks',
                              labelStyle: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (remarks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter remarks'),
                    ),
                  );
                  return;
                } else {
                  // Mark in process logic goes here
                  await Provider.of<GrievanceProvider>(context, listen: false)
                      .markInProcessGrievanceWithRemarks(
                          widget.grievance.grievanceId,
                          remarks,
                          widget.userType);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary),
              child: const Text('Mark in Process'),
            ),
          ],
        );
      },
    );
  }
}
