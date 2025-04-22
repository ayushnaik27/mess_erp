import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/clerk/services/clerk_service.dart';

class ClerkDialogController extends GetxController {
  final ClerkService _clerkService = Get.find<ClerkService>();
  final AppLogger _logger = AppLogger();

  final RxBool isLoading = false.obs;

  Future<void> addStudent(String name, String rollNumber) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addStudent(name, rollNumber);
      if (success) {
        Get.snackbar(
          'Success',
          'Student added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add student',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error adding student', error: e);
      Get.snackbar(
        'Error',
        'Failed to add student: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addVendor(String name) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addVendor(name);
      if (success) {
        Get.snackbar(
          'Success',
          'Vendor added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add vendor',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error adding vendor', error: e);
      Get.snackbar(
        'Error',
        'Failed to add vendor: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> imposeFine(String rollNumber, double amount) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.imposeStudentFine(rollNumber, amount);
      if (success) {
        Get.snackbar(
          'Success',
          'Fine imposed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to impose fine',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error imposing fine', error: e);
      Get.snackbar(
        'Error',
        'Failed to impose fine: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addManager(String name, String email) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addManager(name, email);
      if (success) {
        Get.snackbar(
          'Success',
          'Manager added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add manager',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error adding manager', error: e);
      Get.snackbar(
        'Error',
        'Failed to add manager: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMuneem(String name, String email) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addMuneem(name, email);
      if (success) {
        Get.snackbar(
          'Success',
          'Muneem added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add muneem',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error adding muneem', error: e);
      Get.snackbar(
        'Error',
        'Failed to add muneem: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCommitteeMember(String name, String email) async {
    try {
      isLoading.value = true;
      final success = await _clerkService.addCommitteeMember(name, email);
      if (success) {
        Get.snackbar(
          'Success',
          'Committee member added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add committee member',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error adding committee member', error: e);
      Get.snackbar(
        'Error',
        'Failed to add committee member: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
