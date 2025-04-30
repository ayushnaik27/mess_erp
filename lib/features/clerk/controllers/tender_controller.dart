import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/index.dart';

class TenderController extends GetxController {
  final AppLogger _logger = AppLogger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthPersistenceService _persistenceService;

  // Add hostelId to track which hostel this controller is for
  final RxString hostelId = ''.obs;
  final RxString username = ''.obs;

  final RxList<TenderItem> tenderItems = <TenderItem>[].obs;
  final Rx<DateTime> deadline = DateTime.now().add(Duration(days: 14)).obs;
  final Rx<DateTime> openingDate = DateTime.now().add(Duration(days: 15)).obs;
  final RxString filePath = ''.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  final RxList<Tender> allTenders = <Tender>[].obs;
  final RxList<Tender> activeTenders = <Tender>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  TenderController({required AuthPersistenceService persistenceService})
      : _persistenceService = persistenceService;

  @override
  void onInit() {
    super.onInit();
    _logger.i('TenderController initializing...');
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final user = await _persistenceService.getCurrentUser();
      if (user != null && user.hostelId.isNotEmpty) {
        hostelId.value = user.hostelId;
        username.value = user.name;
        _logger.i('TenderController initialized for hostel: ${hostelId.value}');

        fetchAndSetTenders();
        fetchAndSetActiveTenders();
      } else {
        _logger.e('Failed to initialize TenderController: No hostel ID found');
        Get.snackbar(
          'Error',
          'Unable to determine your hostel. Please log out and log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error initializing TenderController', error: e);
    }
  }

  void addTenderItem(TenderItem item) {
    tenderItems.add(item);
    _logger.i('Added tender item: ${item.itemName}');
  }

  void updateTenderItem(int index, TenderItem updatedItem) {
    if (index >= 0 && index < tenderItems.length) {
      tenderItems[index] = updatedItem;
      _logger.i('Updated tender item at index $index: ${updatedItem.itemName}');
    }
  }

  void removeTenderItem(int index) {
    if (index >= 0 && index < tenderItems.length) {
      final removedItem = tenderItems[index];
      tenderItems.removeAt(index);
      _logger.i('Removed tender item at index $index: ${removedItem.itemName}');
    }
  }

  void setDeadline(DateTime date) {
    deadline.value = date;
    _logger.i('Set deadline: ${date.toString()}');

    // Ensure opening date is after deadline
    if (openingDate.value.isBefore(date) ||
        openingDate.value.isAtSameMomentAs(date)) {
      openingDate.value = date.add(Duration(days: 1));
      _logger.i('Adjusted opening date to: ${openingDate.value.toString()}');
    }
  }

  void setOpeningDate(DateTime date) {
    openingDate.value = date;
    _logger.i('Set opening date: ${date.toString()}');
  }

  void setFilePath(String path) {
    filePath.value = path;
    _logger.i('Set file path: $path');
  }

  void resetTenderForm() {
    tenderItems.clear();
    deadline.value = DateTime.now().add(Duration(days: 14));
    openingDate.value = DateTime.now().add(Duration(days: 15));
    filePath.value = '';
    uploadProgress.value = 0.0;
    _logger.i('Reset tender form');
  }

  Future<void> fetchAndSetTenders() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch tenders: No hostel ID');
        return;
      }

      isLoading.value = true;
      _logger.i('Fetching all tenders for hostel: ${hostelId.value}');

      final snapshot = await _firestore
          .collection(FirestoreConstants.tenders)
          .where('hostelId', isEqualTo: hostelId.value)
          .get();

      allTenders.value = snapshot.docs.map((doc) {
        return Tender.fromMap(doc.data());
      }).toList();

      _logger.i(
          'Fetched ${allTenders.length} tenders for hostel ${hostelId.value}');
    } catch (e) {
      _logger.e('Error fetching tenders', error: e);
      Get.snackbar(
        'Error',
        'Failed to fetch tenders',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAndSetActiveTenders() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch active tenders: No hostel ID');
        return;
      }

      isLoading.value = true;
      _logger.i('Fetching active tenders for hostel: ${hostelId.value}');

      try {
        final snapshot = await _firestore
            .collection(FirestoreConstants.tenders)
            .where('hostelId', isEqualTo: hostelId.value)
            .where('deadline', isGreaterThanOrEqualTo: DateTime.now())
            .where('status', isEqualTo: 'active')
            .get();

        activeTenders.value = snapshot.docs.map((doc) {
          return Tender.fromMap(doc.data());
        }).toList();

        _logger.i(
            'Fetched ${activeTenders.length} active tenders for hostel ${hostelId.value}');
      } catch (queryError) {
        _logger.w(
            'Index error, falling back to client-side filtering: $queryError');

        final snapshot = await _firestore
            .collection(FirestoreConstants.tenders)
            .where('hostelId', isEqualTo: hostelId.value)
            .get();

        // Filter tenders on the client side
        final now = DateTime.now();
        activeTenders.value = snapshot.docs
            .map((doc) => Tender.fromMap(doc.data()))
            .where((tender) =>
                tender.deadline.isAfter(now) && tender.status == 'active')
            .toList();

        _logger.i(
            'Fetched ${activeTenders.length} active tenders for hostel ${hostelId.value} with client filtering');

        Get.snackbar(
          'Database Index Required',
          'Please create the required database index using the link in the logs. This is a one-time setup.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: Duration(seconds: 7),
          isDismissible: true,
          mainButton: TextButton(
            onPressed: () {
              _openIndexUrl();
            },
            child: Text(
              'CREATE INDEX',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error fetching active tenders', error: e);
      Get.snackbar(
        'Error',
        'Failed to fetch active tenders',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _openIndexUrl() async {
    const String indexUrl =
        'https://console.firebase.google.com/project/messerp-26027/firestore/indexes';

    try {
      if (await canLaunch(indexUrl)) {
        await launch(indexUrl);
      } else {
        _logger.e('Could not launch $indexUrl');
      }
    } catch (e) {
      _logger.e('Error launching index URL', error: e);
    }
  }

  Tender? findById(String id) {
    try {
      return allTenders.firstWhere((tender) => tender.tenderId == id);
    } catch (e) {
      _logger.w('Tender not found with ID: $id');
      return null;
    }
  }

  Future<void> addTender(Tender tender) async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot add tender: No hostel ID');
        throw Exception('Hostel ID not found. Please log in again.');
      }

      isSubmitting.value = true;
      _logger.i('Adding tender: ${tender.title} for hostel: ${hostelId.value}');

      final updatedTender = tender.copyWith(hostelId: hostelId.value);

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(updatedTender.tenderId)
          .set(updatedTender.toMap());

      allTenders.add(updatedTender);
      if (updatedTender.deadline.isAfter(DateTime.now())) {
        activeTenders.add(updatedTender);
      }

      _logger.i('Tender added successfully: ${updatedTender.tenderId}');

      resetTenderForm();
    } catch (e) {
      _logger.e('Error adding tender', error: e);
      throw e;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitBid(String tenderId, Bid bid) async {
    try {
      isSubmitting.value = true;
      _logger.i('Submitting bid for tender: $tenderId');

      final tender = findById(tenderId);
      if (tender == null || tender.hostelId != hostelId.value) {
        throw Exception('Tender not found or not authorized for this hostel');
      }

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'bids': FieldValue.arrayUnion([bid.toMap()]),
      });

      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        final updatedBids = [...allTenders[index].bids, bid];
        allTenders[index] = allTenders[index].copyWith(bids: updatedBids);

        final activeIndex =
            activeTenders.indexWhere((tender) => tender.tenderId == tenderId);
        if (activeIndex != -1) {
          activeTenders[activeIndex] =
              activeTenders[activeIndex].copyWith(bids: updatedBids);
        }
      }

      _logger.i('Bid submitted successfully for tender: $tenderId');
    } catch (e) {
      _logger.e('Error submitting bid', error: e);
      throw e;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> closeTender(String tenderId) async {
    try {
      isSubmitting.value = true;
      _logger.i('Closing tender: $tenderId');

      final tender = findById(tenderId);
      if (tender == null || tender.hostelId != hostelId.value) {
        throw Exception('Tender not found or not authorized for this hostel');
      }

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'status': 'closed',
      });

      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        allTenders[index] = allTenders[index].copyWith(status: 'closed');

        activeTenders.removeWhere((tender) => tender.tenderId == tenderId);
      }

      _logger.i('Tender closed successfully: $tenderId');
    } catch (e) {
      _logger.e('Error closing tender', error: e);
      throw e;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> awardTender(String tenderId, String vendorId) async {
    try {
      isSubmitting.value = true;
      _logger.i('Awarding tender $tenderId to vendor $vendorId');

      final tender = findById(tenderId);
      if (tender == null || tender.hostelId != hostelId.value) {
        throw Exception('Tender not found or not authorized for this hostel');
      }

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'status': 'awarded',
        'awardedTo': vendorId,
        'awardedAt': FieldValue.serverTimestamp(),
      });

      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        allTenders[index] = allTenders[index].copyWith(status: 'awarded');

        activeTenders.removeWhere((tender) => tender.tenderId == tenderId);
      }

      _logger.i('Tender awarded successfully: $tenderId to $vendorId');
    } catch (e) {
      _logger.e('Error awarding tender', error: e);
      throw e;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<List<Tender>> fetchTendersByVendor(String vendorId) async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch vendor tenders: No hostel ID');
        return [];
      }

      isLoading.value = true;
      _logger.i(
          'Fetching tenders for vendor: $vendorId in hostel: ${hostelId.value}');

      final snapshot = await _firestore
          .collection(FirestoreConstants.tenders)
          .where('hostelId', isEqualTo: hostelId.value)
          .get();

      final tenders = snapshot.docs
          .map((doc) => Tender.fromMap(doc.data()))
          .where((tender) => tender.bids.any((bid) => bid.vendorId == vendorId))
          .toList();

      _logger.i('Fetched ${tenders.length} tenders for vendor: $vendorId');
      return tenders;
    } catch (e) {
      _logger.e('Error fetching tenders for vendor', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  void setUploadProgress(double progress) {
    uploadProgress.value = progress;
  }

  void setIsUploading(bool value) {
    isUploading.value = value;
  }

  void setHostelId(String id) {
    if (id.isNotEmpty && id != hostelId.value) {
      hostelId.value = id;
      fetchAndSetTenders();
      fetchAndSetActiveTenders();
    }
  }

  Future<String> uploadTenderFile(String filePath, String title) async {
    try {
      if (filePath.isEmpty) {
        throw Exception('File path is empty');
      }

      isUploading.value = true;
      _logger.i('Uploading tender file: $filePath');

      // Use FirestoreConstants for storage paths
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(FirestoreConstants.storagePathTenders)
          .child('${DateTime.now().millisecondsSinceEpoch}_$title');

      UploadTask uploadTask = ref.putFile(File(filePath));

      // Listen to upload progress events
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
      });

      // Wait for upload to complete
      await uploadTask;
      String fileUrl = await ref.getDownloadURL();

      _logger.i('File uploaded successfully: $fileUrl');
      return fileUrl;
    } catch (e) {
      _logger.e('Error uploading file', error: e);
      throw e;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> submitTender(
      {required String title,
      required String description,
      required List<TenderItem> items,
      required DateTime deadline,
      required DateTime openingDate,
      required String filePath}) async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot submit tender: No hostel ID');
        throw Exception('Hostel ID not found. Please log in again.');
      }

      isSubmitting.value = true;
      _logger.i('Submitting tender: $title for hostel: ${hostelId.value}');

      String fileUrl = '';
      if (filePath.isNotEmpty) {
        try {
          fileUrl = await uploadTenderFile(filePath, title);
        } catch (uploadError) {
          _logger.e('Error uploading file (continuing with empty URL)',
              error: uploadError);
          fileUrl = "https://placeholder.url/document-pending";
        }
      }

      final tender = Tender(
        tenderId: 'T${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        tenderItems: items,
        deadline: deadline,
        openingDate: openingDate,
        fileUrl: fileUrl,
        status: 'active',
        hostelId: hostelId.value,
        bids: [],
      );

      await addTender(tender);

      _logger.i('Tender submitted successfully: ${tender.tenderId}');
      return;
    } catch (e) {
      _logger.e('Error submitting tender', error: e);
      throw e;
    } finally {
      isSubmitting.value = false;
    }
  }
}
