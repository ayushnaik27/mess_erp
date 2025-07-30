import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/providers/grievance_provider.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class FileGrievanceScreen extends StatefulWidget {
  static const routeName = '/fileGrievance';

  const FileGrievanceScreen({super.key});

  @override
  State<FileGrievanceScreen> createState() => _FileGrievanceScreenState();
}

class _FileGrievanceScreenState extends State<FileGrievanceScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String? _filePath = '';
  DateTime selectedDate = DateTime.now();
  String selectedMeal = '';

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    log(selectedDate.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('File Grievance', style: theme.textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Date: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            selectedDate = value;
                            selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                DateTime.now().hour,
                                DateTime.now().minute);
                            log("Selected date: $selectedDate");
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              DropdownButtonFormField(
                  hint: const Text('Select meal'),
                  value: '',
                  items: [
                    const DropdownMenuItem(
                        value: '', child: Text('Select meal')),
                    if ((selectedDate == DateTime.now() &&
                            DateTime.now().hour > 7) ||
                        selectedDate.day ==
                            DateTime.now()
                                .subtract(const Duration(days: 1))
                                .day)
                      const DropdownMenuItem(
                          value: 'breakfast', child: Text('Breakfast')),
                    if ((selectedDate == DateTime.now() &&
                            DateTime.now().hour > 12) ||
                        selectedDate.day ==
                            DateTime.now()
                                .subtract(const Duration(days: 1))
                                .day)
                      const DropdownMenuItem(
                          value: 'lunch', child: Text('Lunch')),
                    if ((selectedDate == DateTime.now() &&
                            DateTime.now().hour > 19) ||
                        selectedDate.day ==
                            DateTime.now()
                                .subtract(const Duration(days: 1))
                                .day)
                      const DropdownMenuItem(
                          value: 'Dinner', child: Text('Dinner')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMeal = value.toString();
                      log("Selected meal: $selectedMeal");
                    });
                  }),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Grievance Title',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                controller: titleController,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Grievance Description',
                  labelStyle: theme.textTheme.bodyMedium,
                ),
                maxLines: 3,
                controller: descController,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    setState(() {
                      _filePath = result.files.single.path;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  textStyle: theme.textTheme.bodySmall,
                ),
                child: Column(
                  children: [
                    Text('Upload Supporting Document (if any)',
                        style: theme.textTheme.bodySmall),
                    Text('PDF only',
                        style: TextStyle(
                            fontSize: 8, color: theme.colorScheme.tertiary)),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill all the fields',
                            style: theme.textTheme.bodyMedium),
                      ),
                    );
                    return;
                  }
                  submitGrievance(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodyMedium,
                ),
                child: Text('Submit', style: theme.textTheme.bodyMedium),

                  return;
                }
                submitGrievance(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                textStyle: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitGrievance(BuildContext context) async {
    String grievanceId = generateGrievanceId();
    DateTime timestamp = selectedDate;
    MyUser user =
        await Provider.of<UserProvider>(context, listen: false).getUser();
    String rollNumber = user.username;
    String name = user.name;
    String fileUrl = '';

    if (_filePath != '') {
      Reference ref =
          FirebaseStorage.instance.ref().child('grievances').child(grievanceId);
      await ref.putFile(File(_filePath!));
      fileUrl = await ref.getDownloadURL();
      print('File uploaded to $fileUrl');
    }

    Grievance grievance = Grievance(
      grievanceId: grievanceId,
      studentRollNo: rollNumber,
      name: name,
      dateOfFiling: timestamp,
      grievanceTitle: titleController.text,
      grievanceDesc: descController.text,
      fileUpload: fileUrl,
      status: 'pending',
      assignedTo: 'manager',
      history: [
        {
          'updatedBy': name,
          'date': timestamp,
          'action': 'Assigned to manager',
          'remarks': 'Assigned to manager'
        }
      ],
      reminderCount: 0,
    );

    await Provider.of<GrievanceProvider>(context, listen: false)
        .fileGrievance(grievance);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grievance filed successfully',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
    Navigator.of(context).pop();
  }

  String generateGrievanceId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 10000}';
  }
}
