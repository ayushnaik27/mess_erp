import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/models/item_model.dart';

class AddItemController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _authService;

  // Observable properties
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString hostelId = ''.obs;
  final RxList<Item> items = <Item>[].obs;
  final RxList<String> categories = <String>[].obs;

  // Form fields
  final Rx<String?> selectedItem = Rx<String?>(null);
  final Rx<String?> selectedCategory = Rx<String?>(null);
  final RxBool isOtherItem = false.obs;
  final Rx<double> ratePerUnit = 0.0.obs;
  final Rx<int> quantityReceived = 0.obs;

  // Text controllers
  final TextEditingController otherItemController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // Callback for adding an item
  final Function(ItemEntry)? onAddItem;

  // Constructor with dependency injection
  AddItemController({
    required AuthPersistenceService authService,
    this.onAddItem,
  }) : _authService = authService;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  @override
  void onClose() {
    otherItemController.dispose();
    rateController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  // Initialize user information
  Future<void> _initializeUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        hostelId.value = user.hostelId;
        await Future.wait([
          fetchItems(),
          fetchCategories(),
        ]);
      } else {
        _logger.e('No authenticated user found');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      _logger.e('Error initializing user', error: e);
    }
  }

  // Fetch items for the current hostel
  Future<void> fetchItems() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection(FirestoreConstants.stockItems)
          .where('hostelId', isEqualTo: hostelId.value)
          .orderBy('name')
          .get();

      final List<Item> itemsList = snapshot.docs.map((doc) {
        return Item.fromMap(doc.data(), doc.id);
      }).toList();

      items.value = itemsList;

      // Set default selected item if available
      if (items.isNotEmpty) {
        final attaItem =
            items.firstWhereOrNull((item) => item.name.toLowerCase() == 'atta');
        selectedItem.value = attaItem?.name ?? items.first.name;
      }

      _logger.i('Fetched ${items.length} items for hostel ${hostelId.value}');
    } catch (e) {
      _logger.e('Error fetching items', error: e);
      Get.snackbar(
        'Error',
        'Failed to load items. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch categories for the current hostel
  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.stockCategories)
          .where('hostelId', isEqualTo: hostelId.value)
          .orderBy('name')
          .get();

      final List<String> categoriesList = snapshot.docs.map((doc) {
        return doc.data()['name'] as String;
      }).toList();

      categories.value = categoriesList;

      // Set default selected category if available
      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      _logger.e('Error fetching categories', error: e);
    }
  }

  // Method to set the selected item
  void setSelectedItem(String? value) {
    selectedItem.value = value;
    isOtherItem.value = value == null || value.isEmpty;
  }

  // Method to set the selected category
  void setSelectedCategory(String? value) {
    selectedCategory.value = value;
  }

  // Validate form inputs
  String? validateForm() {
    if (isOtherItem.value && (otherItemController.text.isEmpty)) {
      return 'Please enter the item name';
    }

    if (ratePerUnit.value <= 0) {
      return 'Please enter a valid rate per unit';
    }

    if (quantityReceived.value <= 0) {
      return 'Please enter a valid quantity';
    }

    if (selectedCategory.value == null || selectedCategory.value!.isEmpty) {
      return 'Please select a category';
    }

    return null; // No error
  }

  // Add a new item or edit existing item
  Future<bool> submitItem() async {
    final error = validateForm();
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

      final String itemName = isOtherItem.value
          ? otherItemController.text.trim()
          : selectedItem.value!;

      // Find category ID
      String categoryId = '';
      final categoryDoc = await _firestore
          .collection(FirestoreConstants.stockCategories)
          .where('hostelId', isEqualTo: hostelId.value)
          .where('name', isEqualTo: selectedCategory.value)
          .limit(1)
          .get();

      if (categoryDoc.docs.isNotEmpty) {
        categoryId = categoryDoc.docs.first.id;
      }

      if (isOtherItem.value) {
        // Add new item
        await _firestore.collection(FirestoreConstants.stockItems).add({
          'name': itemName,
          'ratePerUnit': ratePerUnit.value,
          'categoryId': categoryId,
          'hostelId': hostelId.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _logger.i('Added new item: $itemName');
      } else {
        // Edit existing item
        final existingItem = items.firstWhere(
          (item) => item.name == selectedItem.value,
          orElse: () => Item(
            id: '',
            name: '',
            ratePerUnit: 0,
            categoryId: '',
            hostelId: hostelId.value,
            updatedAt: DateTime.now(),
          ),
        );

        if (existingItem.id.isNotEmpty) {
          await _firestore
              .collection(FirestoreConstants.stockItems)
              .doc(existingItem.id)
              .update({
            'ratePerUnit': ratePerUnit.value,
            'categoryId': categoryId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          _logger.i('Updated item: $itemName');
        }
      }

      // If onAddItem callback exists, call it
      if (onAddItem != null) {
        onAddItem!(ItemEntry(
          itemName: itemName,
          ratePerUnit: ratePerUnit.value,
          quantityReceived: quantityReceived.value,
        ));
      }

      Get.back();
      return true;
    } catch (e) {
      _logger.e('Error submitting item', error: e);
      Get.snackbar(
        'Error',
        'Failed to save item: ${e.toString()}',
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

// Keep the ItemEntry model for compatibility with existing code
class ItemEntry {
  final String itemName;
  final double ratePerUnit;
  final int quantityReceived;

  ItemEntry({
    required this.itemName,
    required this.ratePerUnit,
    required this.quantityReceived,
  });
}
