import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/models/index.dart';

class IssueStockController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _authService;

  // Observable properties
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString hostelId = ''.obs;
  final RxDouble totalBalance = 0.0.obs;

  // Stock data
  final RxList<StockItem> stockItems = <StockItem>[].obs;
  final Rx<StockItem?> selectedItem = Rx<StockItem?>(null);
  final RxInt quantityToIssue = 0.obs;
  final RxInt availableQuantity = 0.obs;

  // Text controller for quantity input
  final TextEditingController quantityController = TextEditingController();

  // Constructor with dependency injection
  IssueStockController({
    required AuthPersistenceService authService,
  }) : _authService = authService;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  @override
  void onClose() {
    quantityController.dispose();
    super.onClose();
  }

  // Initialize user and load initial data
  Future<void> _initializeUser() async {
    try {
      isLoading.value = true;

      final user = await _authService.getCurrentUser();
      if (user != null) {
        hostelId.value = user.hostelId;
        await fetchStockItems();
        calculateTotalBalance();
      } else {
        _logger.e('No authenticated user found');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _logger.e('Error initializing user', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all stock items for the current hostel
  Future<void> fetchStockItems() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch stock items: No hostel ID');
        return;
      }

      final snapshot = await _firestore
          .collection(FirestoreConstants.stock)
          .where('hostelId', isEqualTo: hostelId.value)
          .orderBy('name')
          .get();

      final List<StockItem> items = snapshot.docs.map((doc) {
        return StockItem.fromMap(doc.data(), doc.id);
      }).toList();

      stockItems.value = items;

      // Set default selected item if list is not empty
      if (items.isNotEmpty) {
        setSelectedItem(items.first);
      }

      _logger.i(
          'Fetched ${items.length} stock items for hostel ${hostelId.value}');
    } catch (e) {
      _logger.e('Error fetching stock items', error: e);
      Get.snackbar(
        'Error',
        'Failed to load stock items. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Calculate total stock balance
  void calculateTotalBalance() {
    double total = 0;
    for (var item in stockItems) {
      total += item.balance;
    }
    totalBalance.value = total;
  }

  // Set the selected item
  void setSelectedItem(StockItem? item) {
    selectedItem.value = item;
    if (item != null) {
      availableQuantity.value = item.quantity;
    } else {
      availableQuantity.value = 0;
    }

    // Reset quantity input when item changes
    quantityController.text = '';
    quantityToIssue.value = 0;
  }

  // Set quantity to issue
  void setQuantityToIssue(String value) {
    final parsedValue = int.tryParse(value) ?? 0;
    quantityToIssue.value = parsedValue;
  }

  // Validate input before submitting
  String? validateInput() {
    if (selectedItem.value == null) {
      return 'Please select an item';
    }

    if (quantityToIssue.value <= 0) {
      return 'Please enter a valid quantity to issue';
    }

    if (quantityToIssue.value > availableQuantity.value) {
      return 'Cannot issue more than available quantity';
    }

    return null; // No error
  }

  // Issue stock to mess
  Future<bool> issueStock() async {
    final error = validateInput();
    if (error != null) {
      Get.snackbar(
        'Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSubmitting.value = true;

      final item = selectedItem.value!;
      final amount = item.ratePerUnit * quantityToIssue.value;

      // Create batch write for atomicity
      final batch = _firestore.batch();

      // 1. Update stock quantity
      final stockRef =
          _firestore.collection(FirestoreConstants.stock).doc(item.id);
      batch.update(stockRef, {
        'quantity': FieldValue.increment(-quantityToIssue.value),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add transaction record
      final transactionRef =
          _firestore.collection(FirestoreConstants.stockTransactions).doc();
      final stockTransaction = StockTransaction(
        id: transactionRef.id,
        itemId: item.id,
        itemName: item.name,
        hostelId: hostelId.value,
        quantity: quantityToIssue.value,
        amount: amount,
        type: 'issue',
        date: DateTime.now(),
        issuedTo: 'mess',
      );

      batch.set(transactionRef, stockTransaction.toMap());

      // Commit the batch
      await batch.commit();

      // Update local state
      final updatedItem = item.copyWith(
        quantity: item.quantity - quantityToIssue.value,
        updatedAt: DateTime.now(),
      );

      final itemIndex =
          stockItems.indexWhere((element) => element.id == item.id);
      if (itemIndex != -1) {
        stockItems[itemIndex] = updatedItem;
      }

      selectedItem.value = updatedItem;
      availableQuantity.value = updatedItem.quantity;
      calculateTotalBalance();

      // Reset input
      quantityController.text = '';
      quantityToIssue.value = 0;

      _logger
          .i('Issued ${quantityToIssue.value} units of ${item.name} to mess');

      Get.snackbar(
        'Success',
        'Issued ${quantityToIssue.value} units of ${item.name} to mess',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      _logger.e('Error issuing stock', error: e);
      Get.snackbar(
        'Error',
        'Failed to issue stock: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
