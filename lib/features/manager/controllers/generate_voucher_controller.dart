import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/models/index.dart';

class GenerateVoucherController extends GetxController {
  // Dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _authService;

  // Observable properties
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString hostelId = ''.obs;

  // Selection state
  final RxString selectedMonth = ''.obs;
  final RxString selectedVendor = ''.obs;
  final RxString selectedVendorId = ''.obs;
  final RxString selectedDateRange = ''.obs;

  // Data collections
  final RxList<Vendor> vendors = <Vendor>[].obs;
  final RxList<Bill> bills = <Bill>[].obs;

  // Constants
  final List<Map<String, String>> months = [
    {'value': '1', 'label': 'January'},
    {'value': '2', 'label': 'February'},
    {'value': '3', 'label': 'March'},
    {'value': '4', 'label': 'April'},
    {'value': '5', 'label': 'May'},
    {'value': '6', 'label': 'June'},
    {'value': '7', 'label': 'July'},
    {'value': '8', 'label': 'August'},
    {'value': '9', 'label': 'September'},
    {'value': '10', 'label': 'October'},
    {'value': '11', 'label': 'November'},
    {'value': '12', 'label': 'December'},
  ];

  final List<Map<String, String>> dateRanges = [
    {'value': '0', 'label': 'Day 1 to 15'},
    {'value': '1', 'label': 'Day 16 to End of Month'},
  ];

  // Constructor with dependency injection
  GenerateVoucherController({
    required AuthPersistenceService authService,
  }) : _authService = authService;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      isLoading.value = true;

      final user = await _authService.getCurrentUser();
      if (user != null) {
        hostelId.value = user.hostelId;
        await fetchVendors();
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

  Future<void> fetchVendors() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch vendors: hostelId is empty');
        return;
      }

      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('vendors')
          .orderBy('name')
          .get();

      vendors.value = snapshot.docs.map((doc) {
        return Vendor.fromMap(doc.data(), doc.id);
      }).toList();

      _logger
          .i('Fetched ${vendors.length} vendors for hostel ${hostelId.value}');
    } catch (e) {
      _logger.e('Error fetching vendors', error: e);
      Get.snackbar(
        'Error',
        'Failed to load vendors. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void setSelectedMonth(String? value) {
    if (value != null) {
      selectedMonth.value = value;
      bills.clear();
    }
  }

  void setSelectedVendor(Vendor? vendor) {
    if (vendor != null) {
      selectedVendor.value = vendor.name;
      selectedVendorId.value = vendor.id;
    } else {
      selectedVendor.value = '';
      selectedVendorId.value = '';
    }
    bills.clear();
  }

  void setSelectedDateRange(String? value) {
    if (value != null) {
      selectedDateRange.value = value;
      if (selectedMonth.isNotEmpty && selectedVendorId.isNotEmpty) {
        fetchBillsForVoucher();
      }
    }
  }

  // Fetch bills for voucher based on selected criteria - CORRECTED FOR PROPER SCHEMA
  Future<void> fetchBillsForVoucher() async {
    try {
      if (selectedMonth.isEmpty ||
          selectedVendorId.isEmpty ||
          selectedDateRange.isEmpty ||
          hostelId.isEmpty) {
        _logger.e('Cannot fetch bills: Missing required parameters');
        return;
      }

      isLoading.value = true;
      bills.clear();

      final int monthInt = int.parse(selectedMonth.value);
      final int year = DateTime.now().year;

      // Create date range based on selection
      DateTime startDate;
      DateTime endDate;

      if (selectedDateRange.value == '0') {
        // Day 1-15
        startDate = DateTime(year, monthInt, 1);
        endDate = DateTime(year, monthInt, 15, 23, 59, 59);
      } else {
        startDate = DateTime(year, monthInt, 16);
        endDate = DateTime(year, monthInt + 1, 0, 23, 59, 59);
      }

      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('bills')
          .where('vendorId', isEqualTo: selectedVendorId.value)
          .where('billDate', isGreaterThanOrEqualTo: startDate)
          .where('billDate', isLessThanOrEqualTo: endDate)
          .where('isIncludedInVoucher', isEqualTo: false)
          .orderBy('billDate', descending: false)
          .get();

      final List<Bill> fetchedBills = snapshot.docs.map((doc) {
        return Bill.fromMap(doc.data(), doc.id);
      }).toList();

      bills.value = fetchedBills;

      _logger.i('Fetched ${bills.length} bills for voucher');
    } catch (e) {
      _logger.e('Error fetching bills for voucher', error: e);
      Get.snackbar(
        'Error',
        'Failed to load bills. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Generate voucher from selected bills - CORRECTED FOR PROPER SCHEMA
  Future<bool> generateVoucher() async {
    try {
      if (bills.isEmpty) {
        Get.snackbar(
          'Error',
          'There are no bills to generate voucher for!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (selectedMonth.isEmpty ||
          selectedVendorId.isEmpty ||
          selectedDateRange.isEmpty ||
          hostelId.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select all required fields!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      isSubmitting.value = true;

      // Calculate total amount
      double totalAmount = bills.fold(0, (sum, bill) => sum + bill.billAmount);

      // CORRECT PATH: Create voucher document in the hostel's vouchers subcollection
      final voucherRef = _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId.value)
          .collection('vouchers')
          .doc();

      final voucher = Voucher(
        id: voucherRef.id,
        vendorId: selectedVendorId.value,
        vendorName: selectedVendor.value,
        totalAmount: totalAmount,
        dateGenerated: DateTime.now(),
        billIds: bills.map((bill) => bill.id).toList(),
        status: 'pending',
        hostelId: hostelId.value,
      );

      // Use batch write to ensure atomicity
      final batch = _firestore.batch();

      // Add voucher
      batch.set(voucherRef, voucher.toMap());

      // Update all bills to mark them as included in voucher
      for (var bill in bills) {
        final billRef = _firestore
            .collection(FirestoreConstants.hostels)
            .doc(hostelId.value)
            .collection('bills')
            .doc(bill.id);

        batch.update(billRef, {
          'isIncludedInVoucher': true,
          'voucherId': voucherRef.id,
        });
      }

      // Commit the batch
      await batch.commit();

      _logger
          .i('Generated voucher ${voucherRef.id} with ${bills.length} bills');

      Get.snackbar(
        'Success',
        'Voucher generated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear selection and bills
      bills.clear();

      return true;
    } catch (e) {
      _logger.e('Error generating voucher', error: e);
      Get.snackbar(
        'Error',
        'Failed to generate voucher: ${e.toString()}',
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
