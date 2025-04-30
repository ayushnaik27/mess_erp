import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/committee/models/committee_user.dart';

class CommitteeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  Future<CommitteeUser?> getCommitteeUserById(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final userData = docSnap.data() as Map<String, dynamic>;
        _logger.i('Retrieved committee user by ID: $userId');

        return CommitteeUser(
          id: docSnap.id,
          name: userData['name'] ?? '',
          username: userData['email'] ?? '',
          password: userData['password'] ?? '',
          role: userData['role'] ?? '',
          email: userData['email'] ?? '',
          hostelId: userData['hostelId'] ?? '',
        );
      }

      _logger.w('No committee user found with ID: $userId');
      return null;
    } catch (e) {
      _logger.e('Error getting committee user by ID: $e');
      throw Exception('Failed to get committee user by ID: $e');
    }
  }

  // Keep the existing getCommitteeUser but modify it to accept hostelId
  Future<CommitteeUser?> getCommitteeUser({String? hostelId}) async {
    try {
      // Approach 1: If hostelId is provided, use it to form the document ID
      if (hostelId != null && hostelId.isNotEmpty) {
        final docRef =
            _firestore.collection('users').doc('committee_$hostelId');
        final docSnap = await docRef.get();

        if (docSnap.exists) {
          final userData = docSnap.data() as Map<String, dynamic>;
          _logger.i('Retrieved committee user for hostel: $hostelId');

          return CommitteeUser(
            id: docSnap.id,
            name: userData['name'] ?? '',
            username: userData['email'] ?? '',
            password: userData['password'] ?? '',
            role: userData['role'] ?? '',
            email: userData['email'] ?? '',
            hostelId: userData['hostelId'] ?? '',
          );
        }
      }

      // Approach 2: If hostelId is not provided, query by role
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'committee')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        _logger.i('Retrieved committee user by role');

        return CommitteeUser(
          id: querySnapshot.docs.first.id,
          name: userData['name'] ?? '',
          username: userData['email'] ?? '',
          password: userData['password'] ?? '',
          role: userData['role'] ?? '',
          email: userData['email'] ?? '',
          hostelId: userData['hostelId'] ?? '',
        );
      }

      _logger.w('No committee user found');
      return null;
    } catch (e) {
      _logger.e('Error getting committee user: $e');
      throw Exception('Failed to get committee user: $e');
    }
  }
}
