import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/index.dart';

class TenderController extends GetxController {
  final AppLogger _logger = AppLogger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  void onInit() {
    super.onInit();
    _logger.i('TenderController initialized');
    fetchAndSetTenders();
    fetchAndSetActiveTenders();
  }

  // For tender creation flow
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

  // Tender management methods
  Future<void> fetchAndSetTenders() async {
    try {
      isLoading.value = true;
      _logger.i('Fetching all tenders');

      final snapshot =
          await _firestore.collection(FirestoreConstants.tenders).get();

      allTenders.value = snapshot.docs.map((doc) {
        return Tender.fromMap(doc.data());
      }).toList();

      _logger.i('Fetched ${allTenders.length} tenders');
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
      isLoading.value = true;
      _logger.i('Fetching active tenders');

      try {
        // Try the compound query first
        final snapshot = await _firestore
            .collection(FirestoreConstants.tenders)
            .where('deadline', isGreaterThanOrEqualTo: DateTime.now())
            .where('status', isEqualTo: 'active')
            .get();

        activeTenders.value = snapshot.docs.map((doc) {
          return Tender.fromMap(doc.data());
        }).toList();

        _logger.i('Fetched ${activeTenders.length} active tenders');
      } catch (queryError) {
        // If the index doesn't exist, fall back to client-side filtering
        _logger.w(
            'Index error, falling back to client-side filtering: $queryError');

        final snapshot =
            await _firestore.collection(FirestoreConstants.tenders).get();

        // Filter tenders on the client side
        final now = DateTime.now();
        activeTenders.value = snapshot.docs
            .map((doc) => Tender.fromMap(doc.data()))
            .where((tender) =>
                tender.deadline.isAfter(now) && tender.status == 'active')
            .toList();

        _logger.i(
            'Fetched ${activeTenders.length} active tenders with client filtering');

        // Show a one-time message to create the index
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

  // Helper method to open the index creation URL
  void _openIndexUrl() async {
    const String indexUrl =
        'https://console.firebase.google.com/project/messerp-26027/firestore/indexes';

    try {
      // Use url_launcher package to open the URL
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
      isSubmitting.value = true;
      _logger.i('Adding tender: ${tender.title}');

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tender.tenderId)
          .set(tender.toMap());

      // Add to local list
      allTenders.add(tender);
      if (tender.deadline.isAfter(DateTime.now())) {
        activeTenders.add(tender);
      }

      _logger.i('Tender added successfully: ${tender.tenderId}');

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

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'bids': FieldValue.arrayUnion([bid.toMap()]),
      });

      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        final tender = allTenders[index];
        final updatedBids = [...tender.bids, bid];
        allTenders[index] = tender.copyWith(bids: updatedBids);

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

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'status': 'closed',
      });

      // Update local tender object
      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        allTenders[index] = allTenders[index].copyWith(status: 'closed');

        // Remove from active tenders
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

      await _firestore
          .collection(FirestoreConstants.tenders)
          .doc(tenderId)
          .update({
        'status': 'awarded',
        'awardedTo': vendorId,
        'awardedAt': FieldValue.serverTimestamp(),
      });

      // Update local tender object
      final index =
          allTenders.indexWhere((tender) => tender.tenderId == tenderId);
      if (index != -1) {
        allTenders[index] = allTenders[index].copyWith(status: 'awarded');

        // Remove from active tenders
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
      isLoading.value = true;
      _logger.i('Fetching tenders for vendor: $vendorId');

      final snapshot = await _firestore
          .collection(FirestoreConstants.tenders)
          .where('bids', arrayContains: {'vendorId': vendorId}).get();

      final tenders = snapshot.docs.map((doc) {
        return Tender.fromMap(doc.data());
      }).toList();

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
}
