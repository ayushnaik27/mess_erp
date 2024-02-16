import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mess_erp/providers/announcement_provider.dart';

class AddAnnouncementScreen extends StatefulWidget {
  static const routeName = '/addAnnouncement';
  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _filePath;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Announcement'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16.0),
              _filePath != null
                  ? Container(child: Image.file(File(_filePath!)))
                  : Container(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_filePath == null) {
                    Announcement newAnnouncement = Announcement(
                      title: _titleController.text,
                      description: _descriptionController.text,
                    );
                    AnnouncementServices().uploadAnnouncementWithoutFile(
                        newAnnouncement);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Announcement Added'),
                      ),
                    );
                    Navigator.pop(
                        context); // Return to the previous screen after adding announcement
                    return;
                  }
                  Announcement newAnnouncement = Announcement(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    file: File(_filePath!),
                  );
                  AnnouncementServices().uploadAnnouncement(
                      newAnnouncement, newAnnouncement.file);
                  // Call the function to upload announcement
                  // You may want to use a service or repository for this
                  // e.g., announcementService.uploadAnnouncement(newAnnouncement, _filePath);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement Added'),
                    ),
                  );
                  Navigator.pop(
                      context); // Return to the previous screen after adding announcement
                },
                child: const Text('Add Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
