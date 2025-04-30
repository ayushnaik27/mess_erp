import 'package:mess_erp/core/services/hive_service.dart';
import 'package:mess_erp/core/services/shared_prefs_service.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';

class AuthPersistenceService {
  static AuthPersistenceService? _instance;
  final AppLogger _logger = AppLogger();
  SharedPrefsService? _prefsService;
  HiveService? _hiveService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInitialized = false;

  AuthPersistenceService._();

  static Future<AuthPersistenceService> getInstance() async {
    if (_instance == null) {
      _instance = AuthPersistenceService._();
      await _instance!.init();
    } else if (!_instance!._isInitialized) {
      await _instance!.init();
    }
    return _instance!;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefsService = await SharedPrefsService.getInstance();
      _hiveService = await HiveService.getInstance();
      _isInitialized = true;
      _logger.i('AuthPersistenceService initialized');
    } catch (e) {
      _logger.e('Failed to initialize AuthPersistenceService', error: e);
      _isInitialized = false;
    }
  }

  bool isLoggedIn() {
    if (!_isInitialized || _prefsService == null) return false;
    return _prefsService!.isLoggedIn();
  }

  // Changed to async
  Future<User?> getCurrentUser() async {
    if (!_isInitialized) await init();
    if (_hiveService == null) return null;

    try {
      return await _hiveService!.getUser();
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      return null;
    }
  }

  String? getUserRole() {
    if (!_isInitialized || _prefsService == null) return null;
    return _prefsService!.getUserRole();
  }

  String? getUserId() {
    if (!_isInitialized || _prefsService == null) return null;
    return _prefsService!.getUserId();
  }

  Future<bool> persistUserLogin(User user, {String? authToken}) async {
    if (!_isInitialized) await init();
    if (_prefsService == null || _hiveService == null) return false;

    try {
      await _hiveService!.saveUser(user);

      await _prefsService!.setIsLoggedIn(true);
      await _prefsService!.setUserId(user.id);
      await _prefsService!.setUserRole(user.role);
      await _prefsService!.setLastLoginTime(DateTime.now());

      if (authToken != null) {
        await _prefsService!.setAuthToken(authToken);
      }

      _logger.i('User login persisted: ${user.name}');
      return true;
    } catch (e) {
      _logger.e('Error persisting user login', error: e);
      return false;
    }
  }

  Future<bool> clearUserData() async {
    if (!_isInitialized) await init();
    if (_prefsService == null || _hiveService == null) return false;

    try {
      await _hiveService!.deleteUser();
      await _prefsService!.clearAuthData();

      _logger.i('User data cleared on logout');
      return true;
    } catch (e) {
      _logger.e('Error clearing user data', error: e);
      return false;
    }
  }

  Future<User?> refreshUserData() async {
    if (!_isInitialized) await init();
    if (_prefsService == null || _hiveService == null) return null;

    try {
      final userId = _prefsService!.getUserId();
      final userRole = _prefsService!.getUserRole();

      if (userId == null || userRole == null) {
        _logger.w('Cannot refresh user: missing ID or role');
        return null;
      }

      // Query Firestore for the latest user data
      // (Update this to use the new data structure)
      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _logger.w('User document not found in Firestore');
        return null;
      }

      final user = User.fromFirestore(userDoc.data()!, userId);
      await persistUserLogin(user);

      return user;
    } catch (e) {
      _logger.e('Error refreshing user data', error: e);
      return null;
    }
  }
}
