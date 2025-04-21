import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class ClerkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  Future<User?> getCurrentUser() async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.clerk)
          .doc(FirestoreConstants.adminUsernames[FirestoreConstants.clerk])
          .get();

      if (doc.exists) {
        return User(
          id: doc.id,
          name: doc.data()?[FirestoreConstants.name] ?? 'Admin',
          role: FirestoreConstants.clerk,
          email: doc.data()?[FirestoreConstants.email] ?? '',
          hostel: '',
          rollNumber: '',
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      return null;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      String hashedPassword = HashHelper.encode(newPassword);
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.clerk)
          .doc(FirestoreConstants.adminUsernames[FirestoreConstants.clerk])
          .update({
        FirestoreConstants.password: hashedPassword,
      });

      _logger.i('Password changed successfully');
      return true;
    } catch (e) {
      _logger.e('Error changing password', error: e);
      return false;
    }
  }

  Future<bool> addStudent(String name, String rollNumber) async {
    try {
      String password = HashHelper.encode('12345678');
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.student)
          .doc(rollNumber)
          .set({
        FirestoreConstants.name: name,
        FirestoreConstants.rollNumber: rollNumber,
        'role': FirestoreConstants.student,
        FirestoreConstants.password: password
      });

      _logger.i('Student added: $name');
      return true;
    } catch (e) {
      _logger.e('Error adding student', error: e);
      return false;
    }
  }

  Future<bool> addVendor(String name) async {
    try {
      await _firestore.collection('vendorList').doc(name).set({
        FirestoreConstants.name: name,
      });

      _logger.i('Vendor added: $name');
      return true;
    } catch (e) {
      _logger.e('Error adding vendor', error: e);
      return false;
    }
  }

  Future<bool> imposeStudentFine(String rollNumber, double amount) async {
    try {
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.student)
          .doc(rollNumber)
          .collection('fineDetails')
          .doc()
          .set({
        'amount': FieldValue.increment(amount),
        'date': DateTime.now().toString(),
      }, SetOptions(merge: true));

      _logger.i('Fine imposed on $rollNumber: $amount');
      return true;
    } catch (e) {
      _logger.e('Error imposing fine', error: e);
      return false;
    }
  }

  Future<bool> addManager(String name, String email) async {
    try {
      String password = HashHelper.encode('12345678');
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.manager)
          .doc(email)
          .set({
        FirestoreConstants.name: name,
        FirestoreConstants.email: email,
        'role': FirestoreConstants.manager,
        FirestoreConstants.password: password
      });

      _logger.i('Manager added: $name');
      return true;
    } catch (e) {
      _logger.e('Error adding manager', error: e);
      return false;
    }
  }

  Future<bool> addMuneem(String name, String email) async {
    try {
      String password = HashHelper.encode('12345678');
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.muneem)
          .doc(email)
          .set({
        FirestoreConstants.name: name,
        FirestoreConstants.email: email,
        'role': FirestoreConstants.muneem,
        FirestoreConstants.password: password
      });

      _logger.i('Muneem added: $name');
      return true;
    } catch (e) {
      _logger.e('Error adding muneem', error: e);
      return false;
    }
  }

  Future<bool> addCommitteeMember(String name, String email) async {
    try {
      String password = HashHelper.encode('12345678');
      await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.committee)
          .doc(email)
          .set({
        FirestoreConstants.name: name,
        FirestoreConstants.email: email,
        'role': FirestoreConstants.committee,
        FirestoreConstants.password: password
      });

      _logger.i('Committee member added: $name');
      return true;
    } catch (e) {
      _logger.e('Error adding committee member', error: e);
      return false;
    }
  }

  Future<void> logout() async {}
}
