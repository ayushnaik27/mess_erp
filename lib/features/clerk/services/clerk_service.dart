import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class ClerkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  final AuthPersistenceService _persistenceService;
  final String hostelId;

  ClerkService(this.hostelId, this._persistenceService);

  Future<User?> getCurrentUser() async {
    try {
      final persistedUser = await _persistenceService.getCurrentUser();
      if (persistedUser != null) {
        return persistedUser;
      }

      final userId = 'clerk_$hostelId';
      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return User.fromFirestore(userDoc.data()!, userDoc.id);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      return null;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      final userId = 'clerk_$hostelId';
      String hashedPassword = HashHelper.encode(newPassword);

      await _firestore.collection(FirestoreConstants.users).doc(userId).update({
        'password': hashedPassword,
        'lastUpdated': FieldValue.serverTimestamp(),
        'isFirstLogin': false,
      });

      _logger.i('Password changed successfully for clerk in $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error changing password', error: e);
      return false;
    }
  }

  Future<bool> addStudent(
      String name, String rollNumber, String email, String phoneNumber) async {
    try {
      String password = HashHelper.encode('12345678');

      await _firestore
          .collection(FirestoreConstants.users)
          .doc(rollNumber)
          .set({
        'name': name,
        'rollNumber': rollNumber,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'student',
        'hostelId': hostelId,
        'password': password,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('students')
          .doc(rollNumber)
          .set({
        'name': name,
        'rollNumber': rollNumber,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Student added: $name in hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error adding student', error: e);
      return false;
    }
  }

  Future<bool> addVendor(
      String name, String contactNumber, String email) async {
    try {
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('vendors')
          .doc()
          .set({
        'name': name,
        'contactNumber': contactNumber,
        'email': email,
        'hostelId': hostelId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Vendor added: $name for hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error adding vendor', error: e);
      return false;
    }
  }

  Future<bool> imposeStudentFine(
      String rollNumber, double amount, String reason) async {
    try {
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('students')
          .doc(rollNumber)
          .collection('fines')
          .doc()
          .set({
        'amount': amount,
        'reason': reason,
        'date': FieldValue.serverTimestamp(),
        'paid': false,
        'imposedBy': 'clerk_$hostelId',
      });

      _logger.i('Fine imposed on $rollNumber: $amount in hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error imposing fine', error: e);
      return false;
    }
  }

  Future<bool> addManager(String name, String email, String phoneNumber) async {
    try {
      final userId = 'manager_$hostelId';
      String password = HashHelper.encode('12345678');

      await _firestore.collection(FirestoreConstants.users).doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'manager',
        'hostelId': hostelId,
        'password': password,
        'isActive': true,
        'isFirstLogin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('staff')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'manager',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Manager added: $name for hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error adding manager', error: e);
      return false;
    }
  }

  Future<bool> addMuneem(String name, String email, String phoneNumber) async {
    try {
      final userId = 'muneem_$hostelId';
      String password = HashHelper.encode('12345678');

      await _firestore.collection(FirestoreConstants.users).doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'muneem',
        'hostelId': hostelId,
        'password': password,
        'isActive': true,
        'isFirstLogin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also add to the hostel's staff collection
      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('staff')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'muneem',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Muneem added: $name for hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error adding muneem', error: e);
      return false;
    }
  }

  Future<bool> addCommitteeMember(
      String name, String email, String phoneNumber) async {
    try {
      final userId = 'committee_$hostelId';
      String password = HashHelper.encode('12345678');

      await _firestore.collection(FirestoreConstants.users).doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'committee',
        'hostelId': hostelId,
        'password': password,
        'isActive': true,
        'isFirstLogin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('staff')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'committee',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Committee member added: $name for hostel $hostelId');
      return true;
    } catch (e) {
      _logger.e('Error adding committee member', error: e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('students')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      _logger.e('Error fetching students', error: e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAssignedGrievances() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection('grievances')
          .where('assignedTo', isEqualTo: 'clerk')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      _logger.e('Error fetching assigned grievances', error: e);
      return [];
    }
  }

  Future<void> logout() async {
    // Handled by auth controller
  }
}
