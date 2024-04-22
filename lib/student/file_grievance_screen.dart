import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mess_erp/providers/grievance_provider.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class FileGrievanceScreen extends StatefulWidget {
  static const routeName = '/fileGrievance';

  FileGrievanceScreen({super.key});

  @override
  State<FileGrievanceScreen> createState() => _FileGrievanceScreenState();
}

class _FileGrievanceScreenState extends State<FileGrievanceScreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descController = TextEditingController();
  String? _filePath = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Grievance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Grievance Title'),
              controller: titleController,
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: const InputDecoration(labelText: 'Grievance Description'),
              maxLines: 3,
              controller: descController,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Implement file upload functionality
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null) {
                  setState(() {
                    _filePath = result.files.single.path;
                  });
                }

              },
              child: const Column(
                children: [
                  Text('Upload Supporting Document (if any)'),
                  Text('PDF only', style: TextStyle(fontSize: 8)),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if(titleController.text.isEmpty || descController.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all the fields'),
                    ),
                  );
                  return;
                }
                // Implement grievance submission functionality
                submitGrievance(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void submitGrievance(BuildContext context) async {
    // Generate unique grievance ID
    String grievanceId = generateGrievanceId();

    // Get current timestamp
    DateTime timestamp = DateTime.now();

    // Get student details from provider
    MyUser user = await Provider.of<UserProvider>(context, listen: false).getUser();
    String rollNumber = user.username;
    String name = user.name;
    String fileUrl = '';

    if(_filePath == ''){
      print('No file uploaded');
    }else{
      Reference ref = FirebaseStorage.instance.ref().child('grievances').child(grievanceId);
      await ref.putFile(File(_filePath!));
      fileUrl = await ref.getDownloadURL();
      print('File uploaded to $fileUrl');
    }

    Grievance grievance = Grievance(
      grievanceId: grievanceId,
      studentRollNo: rollNumber, // Get from login
      name: name, // Get from login
      dateOfFiling: timestamp,
      grievanceTitle: titleController.text, // Get from text field
      grievanceDesc: descController.text, // Get from text field
      fileUpload: fileUrl, // Implement file upload and get URL
      status: 'pending',
      assignedTo: 'committee',
      history: [
        {
          'updatedBy': name,
          'date': timestamp,
          'action': 'Assigned to committee',
          'remarks': 'Assigned to committee'
        }
      ],
      reminderCount: 0,
    );

    print(grievance.toMap());

    Provider.of<GrievanceProvider>(context,listen: false).fileGrievance(grievance); // Add your provider here

    // Show success message or navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grievance filed successfully'),
      ),
    );
    Navigator.of(context).pop();
  }

  String generateGrievanceId() {
    // Implement your logic to generate a unique grievance ID
    // Example: Combine current timestamp with a random number
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecondsSinceEpoch % 10000).toString();
  }
}
