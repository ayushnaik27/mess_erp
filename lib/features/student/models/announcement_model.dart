import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final File? file;
  final Timestamp? timestamp;

  Announcement({
    required this.title,
    required this.description,
    this.file,
    this.timestamp,
    this.id = '',
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String? filePath = data['file'];

    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      file: (filePath != null && filePath != 'NoFile') ? File(filePath) : null,
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'file': file?.path ?? 'NoFile',
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
