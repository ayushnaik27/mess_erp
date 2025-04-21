import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class Announcement {
  final String title;
  final String description;
  File? file;
  Timestamp? timestamp;

  Announcement(
      {required this.title,
      required this.description,
      this.file,
      this.timestamp});
}

class AnnouncementServices {
  final CollectionReference _annoucementCollectionReference =
      FirebaseFirestore.instance.collection('announcements');
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> uploadAnnouncement(Announcement announcement, File? file) async {
    try {
      if (file != null) {
        final storageref =
            _firebaseStorage.ref().child('announcements/${announcement.title}');
        await storageref.putFile(file);
        final downloadUrl = await storageref.getDownloadURL();
        announcement.file = File(downloadUrl);
      }
      // Add announcement to firestore
      await _annoucementCollectionReference.add({
        'title': announcement.title,
        'description': announcement.description,
        'file': announcement.file!.path,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> uploadAnnouncementWithoutFile(Announcement announcement) async {
    try {
      // Add announcement to firestore
      await _annoucementCollectionReference.add({
        'title': announcement.title,
        'description': announcement.description,
        'timestamp': FieldValue.serverTimestamp(),
        'file': 'NoFile'
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Announcement>> getAnnouncements() {
    return _annoucementCollectionReference
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement(
          title: doc['title'],
          description: doc['description'],
          file: doc['file']=='NoFile' ? null: File(doc['file']),
          timestamp: doc['timestamp'],
        );
      }).toList();
    });
  }

  Future<void> deleteOldAnnouncements() async {
    final CollectionReference announcementsRef =
        FirebaseFirestore.instance.collection('announcements');
    final QuerySnapshot<Object?> snapshot = await announcementsRef.get();

    for (final DocumentSnapshot<Object?> doc in snapshot.docs) {
      final DateTime timestamp = doc['timestamp'].toDate();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(timestamp);
      if (difference.inDays > 7) {
        await doc.reference.delete();
      }
    }
  }

  void openAnnouncement(String path, {required bool openBill}) async {
    final response = await http.get(Uri.parse(path));
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/${openBill ? '${DateTime.now().month.toString()}_Mess_Bill' : 'announcement.pdf'}';

    await File(tempDocumentPath).writeAsBytes(bytes);
    OpenFilex.open(tempDocumentPath,
        type: openBill ? 'application/pdf' : 'image/jpeg');
  }
}
