import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  // Admin login
  Future<Map<String, dynamic>> adminLogin({
    required String role,
    required String password,
  }) async {
    try {
      String adminUsername;
      switch (role.toLowerCase()) {
        case 'clerk':
          adminUsername = 'admin';
          break;
        case 'manager':
          adminUsername = 'manager@gmail.com';
          break;
        case 'muneem':
          adminUsername = 'muneem@gmail.com';
          break;
        case 'committee':
          adminUsername = 'committee@gmail.com';
          break;
        default:
          return {'success': false, 'message': 'Invalid role selected'};
      }

      final docSnapshot = await _firestore
          .collection('loginCredentials')
          .doc('roles')
          .collection(role.toLowerCase())
          .doc(adminUsername)
          .get();

      if (!docSnapshot.exists) {
        _logger.w('Admin login failed: User does not exist');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final String storedPassword = docSnapshot.data()?['password'] ?? '';
      final String hashedPassword = HashHelper.encode(password);

      if (storedPassword != hashedPassword) {
        _logger.w('Admin login failed: Incorrect password');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      _logger.i('Admin login successful for role: $role');
      return {
        'success': true,
        'data': {
          'username': adminUsername,
          'role': role,
        }
      };
    } catch (e, stack) {
      _logger.e('Admin login error', error: e, stackTrace: stack);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Student login
  Future<Map<String, dynamic>> studentLogin({
    required String username,
    required String password,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(username)
          .get();

      if (!docSnapshot.exists) {
        _logger.w('Student login failed: User does not exist');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final String storedPassword = docSnapshot.data()?['password'] ?? '';
      final String hashedPassword = HashHelper.encode(password);

      if (storedPassword != hashedPassword) {
        _logger.w('Student login failed: Incorrect password');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      _logger.i('Student login successful for: $username');
      return {
        'success': true,
        'data': {
          'username': username,
          'role': 'student',
        }
      };
    } catch (e, stack) {
      _logger.e('Student login error', error: e, stackTrace: stack);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Student registration
  Future<Map<String, dynamic>> registerStudent({
    required String rollNumber,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if roll number already exists
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .get();

      if (documentSnapshot.exists) {
        _logger.w('Registration failed: Roll number already exists');
        return {'success': false, 'message': 'Roll number already exists'};
      }

      // Check if roll number is pending verification
      DocumentSnapshot enrollmentSnapshot =
          await _firestore.collection('enrollments').doc(rollNumber).get();

      if (enrollmentSnapshot.exists) {
        _logger.w('Registration failed: Verification pending');
        return {'success': false, 'message': 'Verification pending'};
      }

      // All checks passed, register the student
      String hashedPassword = HashHelper.encode(password);

      await _firestore.collection('enrollments').doc(rollNumber).set({
        'name': name,
        'password': hashedPassword,
        'rollNumber': rollNumber,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _logger.i('Student registered: $rollNumber');
      return {'success': true, 'message': 'Registered successfully'};
    } catch (e, stack) {
      _logger.e('Registration error', error: e, stackTrace: stack);
      return {
        'success': false,
        'message':
            'Registration failed. Please check your connection and try again.'
      };
    }
  }
}
