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
    required String hostelId,
    required String password,
  }) async {
    if (!_isInitialized) await init();
    try {
      final String userId = '${role}_$hostelId';

      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final String storedPassword = userData['password'] ?? '';
        final String hashedPassword = HashHelper.encode(password);

        if (storedPassword != hashedPassword) {
          _logger.w('Admin login failed: Incorrect password');
          return {'success': false, 'message': 'Invalid credentials'};
        }

        final user = User.fromFirestore(userData, userId);

        await userDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await _persistenceService?.persistUserLogin(user);

        _logger.i('Admin login successful: $role for hostel $hostelId');
        return {
          'success': true,
          'data': {
            'username': userId,
            'role': role,
            'user': user,
          }
        };
      } else {
        final String initialPassword =
            FirestoreConstants.getInitialPassword(hostelId, role);
        final String hashedInitialPassword = HashHelper.encode(password);
        final String expectedHashedPassword =
            HashHelper.encode(initialPassword);

        if (expectedHashedPassword != hashedInitialPassword) {
          _logger.w('Admin login failed: Incorrect initial password');
          return {'success': false, 'message': 'Invalid credentials'};
        }

        final String email = '$role@$hostelId.nitj.ac.in';
        final String name =
            role.substring(0, 1).toUpperCase() + role.substring(1);

        final user = User(
          id: userId,
          name: '$name ($hostelId)',
          email: email,
          role: role.toLowerCase(),
          hostelId: hostelId,
          phoneNumber: '',
          additionalInfo: {'isFirstLogin': true},
        );

        // Store in Firestore
        await _firestore.collection(FirestoreConstants.users).doc(userId).set({
          'name': user.name,
          'email': user.email,
          'role': user.role,
          'hostelId': user.hostelId,
          'password': hashedInitialPassword,
          'isFirstLogin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await _persistenceService?.persistUserLogin(user);

        _logger
            .i('First-time admin login successful: $role for hostel $hostelId');
        return {
          'success': true,
          'data': {
            'username': userId,
            'role': role,
            'user': user,
          }
        };
      }
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
      // Try new structure first
      final userQuery = await _firestore
          .collection(FirestoreConstants.users)
          .where('rollNumber', isEqualTo: username)
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // Fallback to legacy structure
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
        final String hostel = userData['hostel'] ?? 'BH4'; // Default hostel

        final user = User(
          id: username,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: 'student',
          hostelId: hostel,
          rollNumber: username,
          phoneNumber: userData['phoneNumber'],
          additionalInfo: userData,
        );

        // Store in new structure
        await _firestore.collection(FirestoreConstants.users).doc(username).set(
              user.toFirestore()
                ..addAll({
                  'password': storedPassword,
                  'createdAt': FieldValue.serverTimestamp(),
                }),
              SetOptions(merge: true),
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
      } else {
        // Use the new structure
        final userDoc = userQuery.docs.first;
        final userData = userDoc.data();

        final String storedPassword = userData['password'] ?? '';
        final String hashedPassword = HashHelper.encode(password);

        if (storedPassword != hashedPassword) {
          _logger.w('Student login failed: Incorrect password');
          return {'success': false, 'message': 'Invalid credentials'};
        }

        final user = User.fromFirestore(userData, userDoc.id);

        // Update last login
        await userDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await _persistenceService?.persistUserLogin(user);

        _logger.i('Student login successful for: ${user.rollNumber}');
        return {
          'success': true,
          'data': {
            'username': user.id,
            'role': user.role,
            'user': user,
          }
        };
      }
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
      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(rollNumber)
          .get();

      if (userDoc.exists) {
        _logger.w('Registration failed: User already exists');
        return {'success': false, 'message': 'User already exists'};
      }

      final String hashedPassword = HashHelper.encode(password);

      await _firestore
          .collection(FirestoreConstants.users)
          .doc(rollNumber)
          .set({
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'role': 'student',
        'hostelId': hostel,
        'password': hashedPassword,
        'phoneNumber': phoneNumber,
        'isActive': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection(FirestoreConstants.enrollments)
          .doc(rollNumber)
          .set({
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'hostel': hostel,
        'phoneNumber': phoneNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      _logger.i('Student registration submitted: $rollNumber, Hostel: $hostel');
      return {
        'success': true,
        'message': 'Registration submitted successfully'
      };
    } catch (e, stack) {
      _logger.e('Registration error', error: e, stackTrace: stack);
      return {
        'success': false,
        'message': 'Registration failed. Please try again.'
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

  // New method to fetch accessible hostels for user
  Future<List<String>> getUserAccessibleHostels(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) return [];

      final userData = userDoc.data() ?? {};
      final List<dynamic> hostels = userData['accessibleHostels'] ?? [];

      return hostels.cast<String>();
    } catch (e) {
      _logger.e('Error fetching accessible hostels', error: e);
      return [];
    }
  }
}
