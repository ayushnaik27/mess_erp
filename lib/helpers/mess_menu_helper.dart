import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MessMenuHelper {
  static Future<bool> pickDocsFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);

      try {
        final Reference ref = FirebaseStorage.instance.ref().child('mess_menu');

        await ref.putFile(file);
        return true;
      } catch (e) {
        print('Error uploading file: $e');
        return false;
      }
    }
    return false;
  }

  static void viewMessMenu() async {
    final Reference = FirebaseStorage.instance.ref().child('mess_menu');
    final url = await Reference.getDownloadURL();

    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final file =
        await File('${tempDir.path}/mess_menu.pdf').writeAsBytes(bytes);

    OpenFilex.open(file.path);
  }

  static launchGoogleDocs() async {
    final googleDocsUrl = await getGoogleDocsUrl();
    if (await canLaunchUrl(Uri.parse(googleDocsUrl))) {
      await launchUrl(Uri.parse(googleDocsUrl), mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $googleDocsUrl';
    }
  }

  static void setGoogleDocsUrl(String googleDocsUrl) {
    FirebaseFirestore.instance.collection('mess_menu').doc('mess_menu').set({
      'url': googleDocsUrl,
    });
  }

  static Future<String> getGoogleDocsUrl() async {
    return await FirebaseFirestore.instance
        .collection('mess_menu')
        .doc('mess_menu')
        .get()
        .then((value) => value.data()!['url']);
  }
}
