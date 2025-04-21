import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/student/models/announcement_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AppLogger _logger = AppLogger();

  CollectionReference get _announcements =>
      _firestore.collection(FirestoreConstants.announcements);

  Future<void> uploadAnnouncement(Announcement announcement, File? file) async {
    try {
      String? fileUrl;

      if (file != null) {
        final storageRef = _storage.ref().child(
            'announcements/${DateTime.now().millisecondsSinceEpoch}_${announcement.title}');

        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);
        fileUrl = await snapshot.ref.getDownloadURL();
      }

      final announcementData = announcement.toMap();
      if (fileUrl != null) {
        announcementData['file'] = fileUrl;
      }

      await _announcements.add(announcementData);
      _logger.i('Announcement uploaded: ${announcement.title}');
    } catch (e, stack) {
      _logger.e('Error uploading announcement', error: e, stackTrace: stack);
      throw Exception('Failed to upload announcement: $e');
    }
  }

  Future<void> uploadAnnouncementWithoutFile(Announcement announcement) async {
    try {
      final announcementData = announcement.toMap();
      announcementData['file'] = 'NoFile';

      await _announcements.add(announcementData);
      _logger.i('Text announcement uploaded: ${announcement.title}');
    } catch (e, stack) {
      _logger.e('Error uploading text announcement',
          error: e, stackTrace: stack);
      throw Exception('Failed to upload announcement: $e');
    }
  }

  Stream<List<Announcement>> getAnnouncements() {
    return _announcements
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> deleteOldAnnouncements() async {
    try {
      final DateTime oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7));
      final QuerySnapshot snapshot = await _announcements
          .where('timestamp', isLessThan: Timestamp.fromDate(oneWeekAgo))
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final filePath = data['file'];

        if (filePath != null && filePath != 'NoFile') {
          try {
            await _storage.refFromURL(filePath).delete();
          } catch (e) {
            _logger.w('Failed to delete file from storage: $e');
          }
        }

        await doc.reference.delete();
      }

      _logger
          .i('Old announcements cleaned up: ${snapshot.docs.length} deleted');
    } catch (e, stack) {
      _logger.e('Error deleting old announcements',
          error: e, stackTrace: stack);
    }
  }

  Future<void> openAnnouncement(String path, {bool openBill = false}) async {
    try {
      final response = await http.get(Uri.parse(path));

      if (response.statusCode != 200) {
        _logger.e('Failed to download file: ${response.statusCode}');
        throw Exception('Failed to download file');
      }

      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final fileName = openBill
          ? '${DateTime.now().month}_Mess_Bill.pdf'
          : 'announcement_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final tempFilePath = '${tempDir.path}/$fileName';

      await File(tempFilePath).writeAsBytes(bytes);

      final result = await OpenFilex.open(
        tempFilePath,
        type: openBill ? 'application/pdf' : 'application/octet-stream',
      );

      if (result.type != ResultType.done) {
        _logger.w('Failed to open file: ${result.message}');
      }
    } catch (e, stack) {
      _logger.e('Error opening announcement', error: e, stackTrace: stack);
    }
  }

  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final doc = await _announcements.doc(id).get();
      if (doc.exists) {
        return Announcement.fromFirestore(doc);
      }
      return null;
    } catch (e, stack) {
      _logger.e('Error getting announcement', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try {
      final doc = await _announcements.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final filePath = data['file'];

        if (filePath != null && filePath != 'NoFile') {
          try {
            await _storage.refFromURL(filePath).delete();
          } catch (e) {
            _logger.w('Failed to delete file from storage: $e');
          }
        }

        await _announcements.doc(id).delete();
        return true;
      }
      return false;
    } catch (e, stack) {
      _logger.e('Error deleting announcement', error: e, stackTrace: stack);
      return false;
    }
  }
}
