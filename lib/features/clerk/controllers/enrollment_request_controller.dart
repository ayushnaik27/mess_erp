import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';

class EnrollmentRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _persistenceService;

  final RxList<Map<String, dynamic>> enrollmentRequests =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'timestamp'.obs;
  final RxBool sortAscending = false.obs;
  final RxString hostelId = ''.obs;

  EnrollmentRequestController(
      {required AuthPersistenceService persistenceService})
      : _persistenceService = persistenceService;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final user = await _persistenceService.getCurrentUser();
      if (user != null && user.hostelId.isNotEmpty) {
        hostelId.value = user.hostelId;
        _logger.i(
            'EnrollmentRequestController initialized for hostel: ${hostelId.value}');
        fetchEnrollmentRequests();
      } else {
        _logger.e(
            'Failed to initialize EnrollmentRequestController: No hostel ID found');
        Get.snackbar(
          'Error',
          'Unable to determine your hostel. Please log out and log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Error initializing EnrollmentRequestController', error: e);
    }
  }

  Future<void> fetchEnrollmentRequests() async {
    try {
      if (hostelId.isEmpty) {
        _logger.e('Cannot fetch enrollment requests: No hostel ID');
        return;
      }

      isLoading.value = true;
      _logger.i('Fetching enrollment requests for hostel: ${hostelId.value}');

      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreConstants.enrollments)
          .where('hostel', isEqualTo: hostelId.value)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> requests = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        requests.add({
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'rollNumber': data['rollNumber'] ?? 'Unknown',
          'password': data['password'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'hostel': data['hostel'] ?? '',
          'phone': data['phone'] ?? '',
          'room': data['room'] ?? '',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
        });
      }

      enrollmentRequests.value = requests;
      _logger.i(
          'Fetched ${requests.length} enrollment requests for hostel: ${hostelId.value}');
    } catch (e) {
      _logger.e('Error fetching enrollment requests', error: e);
      Get.snackbar(
        'Error',
        'Failed to fetch enrollment requests',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void sortRequests(String field) {
    _logger.i('Sorting requests by $field (ascending: ${sortAscending.value})');

    if (sortBy.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = field;
      sortAscending.value = true;
    }

    enrollmentRequests.sort((a, b) {
      if (field == 'timestamp') {
        Timestamp aTimestamp = a[field] ?? Timestamp.now();
        Timestamp bTimestamp = b[field] ?? Timestamp.now();
        return sortAscending.value
            ? aTimestamp.compareTo(bTimestamp)
            : bTimestamp.compareTo(aTimestamp);
      } else {
        String aValue = a[field]?.toString().toLowerCase() ?? '';
        String bValue = b[field]?.toString().toLowerCase() ?? '';
        return sortAscending.value
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
    });
  }

  List<Map<String, dynamic>> get filteredRequests {
    if (searchQuery.isEmpty) {
      return enrollmentRequests;
    }

    return enrollmentRequests.where((request) {
      String name = request['name']?.toString().toLowerCase() ?? '';
      String rollNumber = request['rollNumber']?.toString().toLowerCase() ?? '';
      String email = request['email']?.toString().toLowerCase() ?? '';
      String room = request['room']?.toString().toLowerCase() ?? '';
      String query = searchQuery.value.toLowerCase();

      return name.contains(query) ||
          rollNumber.contains(query) ||
          email.contains(query) ||
          room.contains(query);
    }).toList();
  }

  Future<void> rejectRequest(String id, String name) async {
    try {
      isProcessing.value = true;
      _logger.i(
          'Rejecting enrollment request: $id ($name) from hostel: ${hostelId.value}');

      await _firestore
          .collection(FirestoreConstants.enrollments)
          .doc(id)
          .delete();

      enrollmentRequests.removeWhere((request) => request['id'] == id);

      Get.snackbar(
        'Success',
        'Enrollment request rejected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      _logger.i('Enrollment request rejected successfully: $id');
    } catch (e) {
      _logger.e('Error rejecting enrollment request', error: e);
      Get.snackbar(
        'Error',
        'Failed to reject request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> approveRequest(Map<String, dynamic> request) async {
    try {
      isProcessing.value = true;
      String id = request['id'];
      String name = request['name'];
      String rollNumber = request['rollNumber'];
      String password =
          request['password']; // This should be the actual password
      String email = request['email'] ?? '';
      String hostel = request['hostel'] ?? hostelId.value;
      String phone = request['phone'] ?? '';
      String room = request['room'] ?? '';

      _logger.i(
          'Approving enrollment request: $id ($name, $rollNumber) for hostel: $hostel');

      String userId = rollNumber;
      _logger.i(
          'Password from enrollment request: ${password.isEmpty ? "EMPTY" : "NOT EMPTY"}');

      final existingUserDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .get();

      await _firestore.collection(FirestoreConstants.users).doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'hostelId': hostel,
        'rollNumber': rollNumber,
        'role': FirestoreConstants.students,
        'room': room,
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': existingUserDoc.exists
            ? (existingUserDoc.data()?['createdAt'])
            : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(userId)
          .set({
        'userId': userId,
        'role': FirestoreConstants.students,
        'password': password,
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': existingUserDoc.exists
            ? (existingUserDoc.data()?['createdAt'])
            : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostel)
          .collection(FirestoreConstants.students)
          .doc(rollNumber)
          .set({
        'name': name,
        'email': email,
        'phone': phone,
        'rollNumber': rollNumber,
        'room': room,
        'userId': userId,
        'isActive': true,
        'hasPaid': false,
        'dues': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection(FirestoreConstants.enrollments)
          .doc(id)
          .delete();

      enrollmentRequests.removeWhere((r) => r['id'] == id);

      Get.snackbar(
        'Success',
        'Student $name approved and added to hostel $hostel',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      _logger.i('Enrollment request approved successfully: $id');
    } catch (e) {
      _logger.e('Error approving enrollment request', error: e);
      Get.snackbar(
        'Error',
        'Failed to approve request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> refreshRequests() async {
    await fetchEnrollmentRequests();
  }

  void setHostelId(String id) {
    if (id.isNotEmpty && id != hostelId.value) {
      hostelId.value = id;
      fetchEnrollmentRequests();
    }
  }
}
