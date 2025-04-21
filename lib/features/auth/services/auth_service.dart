import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/providers/hash_helper.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();
  AuthPersistenceService? _persistenceService;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _persistenceService = await AuthPersistenceService.getInstance();
      _isInitialized = true;
      _logger.i('AuthService initialized');
    } catch (e) {
      _logger.e('Failed to initialize AuthService', error: e);
    }
  }

  bool get isInitialized => _isInitialized;

  Future<bool> isLoggedIn() async {
    if (!_isInitialized) await init();
    return _persistenceService?.isLoggedIn() ?? false;
  }

  Future<User?> getCurrentUser() async {
    if (!_isInitialized) await init();
    return _persistenceService?.getCurrentUser();
  }

  Future<Map<String, dynamic>> adminLogin({
    required String role,
    required String password,
  }) async {
    if (!_isInitialized) await init();
    try {
      final String? adminUsername =
          FirestoreConstants.adminUsernames[role.toLowerCase()];

      if (adminUsername == null) {
        return {'success': false, 'message': 'Invalid role selected'};
      }

      final docSnapshot = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(role.toLowerCase())
          .doc(adminUsername)
          .get();

      if (!docSnapshot.exists) {
        _logger.w('Admin login failed: User does not exist');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final String storedPassword =
          docSnapshot.data()?[FirestoreConstants.password] ?? '';
      final String hashedPassword = HashHelper.encode(password);

      if (storedPassword != hashedPassword) {
        _logger.w('Admin login failed: Incorrect password');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final userData = docSnapshot.data() ?? {};
      final user = User(
        id: adminUsername,
        name: userData['name'] ?? 'Admin',
        email: userData['email'] ?? adminUsername,
        role: role.toLowerCase(),
        hostel: userData['hostel'] ?? '',
        rollNumber: adminUsername,
        phoneNumber: userData['phoneNumber'],
        additionalInfo: userData,
      );

      await _persistenceService?.persistUserLogin(user);

      _logger.i('Admin login successful for role: $role');
      return {
        'success': true,
        'data': {
          'username': adminUsername,
          'role': role,
          'user': user,
        }
      };
    } catch (e, stack) {
      _logger.e('Admin login error', error: e, stackTrace: stack);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> studentLogin({
    required String username,
    required String password,
  }) async {
    if (!_isInitialized) await init();
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.student)
          .doc(username)
          .get();

      if (!docSnapshot.exists) {
        _logger.w('Student login failed: User does not exist');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final String storedPassword =
          docSnapshot.data()?[FirestoreConstants.password] ?? '';
      final String hashedPassword = HashHelper.encode(password);

      if (storedPassword != hashedPassword) {
        _logger.w('Student login failed: Incorrect password');
        return {'success': false, 'message': 'Invalid credentials'};
      }

      final userData = docSnapshot.data() ?? {};
      final user = User(
        id: username,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: 'student',
        hostel: userData['hostel'] ?? '',
        rollNumber: username,
        phoneNumber: userData['phoneNumber'],
        additionalInfo: userData,
      );

      await _persistenceService?.persistUserLogin(user);

      _logger.i('Student login successful for: $username');
      return {
        'success': true,
        'data': {
          'username': username,
          'role': 'student',
          'user': user,
        }
      };
    } catch (e, stack) {
      _logger.e('Student login error', error: e, stackTrace: stack);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> registerStudent({
    required String rollNumber,
    required String name,
    required String email,
    required String password,
    required String hostel,
    String? phoneNumber,
  }) async {
    if (!_isInitialized) await init();
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.student)
          .doc(rollNumber)
          .get();

      if (documentSnapshot.exists) {
        _logger.w('Registration failed: Roll number already exists');
        return {'success': false, 'message': 'Roll number already exists'};
      }

      DocumentSnapshot enrollmentSnapshot = await _firestore
          .collection(FirestoreConstants.enrollments)
          .doc(rollNumber)
          .get();

      if (enrollmentSnapshot.exists) {
        _logger.w('Registration failed: Verification pending');
        return {'success': false, 'message': 'Verification pending'};
      }

      String hashedPassword = HashHelper.encode(password);

      await _firestore
          .collection(FirestoreConstants.enrollments)
          .doc(rollNumber)
          .set({
        FirestoreConstants.name: name,
        FirestoreConstants.password: hashedPassword,
        FirestoreConstants.rollNumber: rollNumber,
        FirestoreConstants.email: email,
        'hostel': hostel,
        'phoneNumber': phoneNumber,
        FirestoreConstants.timestamp: FieldValue.serverTimestamp(),
      });

      _logger.i('Student registered: $rollNumber, Hostel: $hostel');
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

  Future<bool> logout() async {
    if (!_isInitialized) await init();
    try {
      await _persistenceService?.clearUserData();
      return true;
    } catch (e) {
      _logger.e('Logout error', error: e);
      return false;
    }
  }
}
