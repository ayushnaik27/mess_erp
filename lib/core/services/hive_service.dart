import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mess_erp/core/constants/storage_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';

class HiveService {
  static HiveService? _instance;
  final AppLogger _logger = AppLogger();
  bool _isInitialized = false;

  HiveService._();

  static Future<HiveService> getInstance() async {
    _instance ??= HiveService._();
    if (!_instance!._isInitialized) {
      await _instance!._initHive();
    }
    return _instance!;
  }

  Future<void> _initHive() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);

      Hive.registerAdapter(UserAdapter());

      await Hive.openBox(StorageConstants.userBox);
      await Hive.openBox(StorageConstants.settingsBox);
      await Hive.openBox(StorageConstants.cacheBox);

      _isInitialized = true;
      _logger.i('Hive initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Hive', error: e);
      _isInitialized = false;
    }
  }

  Future<void> saveUser(User user) async {
    try {
      final box = Hive.box(StorageConstants.userBox);
      await box.put(StorageConstants.hiveKeyUserData, user);
      _logger.i('User saved to Hive: ${user.name}');
    } catch (e) {
      _logger.e('Error saving user to Hive', error: e);
      rethrow;
    }
  }

  User? getUser() {
    try {
      final box = Hive.box(StorageConstants.userBox);
      return box.get(StorageConstants.hiveKeyUserData);
    } catch (e) {
      _logger.e('Error getting user from Hive', error: e);
      return null;
    }
  }

  Future<void> deleteUser() async {
    try {
      final box = Hive.box(StorageConstants.userBox);
      await box.delete(StorageConstants.hiveKeyUserData);
      _logger.i('User deleted from Hive');
    } catch (e) {
      _logger.e('Error deleting user from Hive', error: e);
      rethrow;
    }
  }

  Future<void> saveData(String boxName, String key, dynamic value) async {
    try {
      final box = Hive.box(boxName);

      if (value is! String &&
          value is! int &&
          value is! double &&
          value is! bool &&
          value != null) {
        value = jsonEncode(value);
      }

      await box.put(key, value);
    } catch (e) {
      _logger.e('Error saving data to Hive', error: e);
      rethrow;
    }
  }

  dynamic getData(String boxName, String key) {
    try {
      final box = Hive.box(boxName);
      final value = box.get(key);

      if (value is String) {
        try {
          return jsonDecode(value);
        } catch (_) {
          return value;
        }
      }

      return value;
    } catch (e) {
      _logger.e('Error getting data from Hive', error: e);
      return null;
    }
  }

  Future<void> deleteData(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      await box.delete(key);
    } catch (e) {
      _logger.e('Error deleting data from Hive', error: e);
      rethrow;
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.clear();
    } catch (e) {
      _logger.e('Error clearing Hive box', error: e);
      rethrow;
    }
  }

  Future<void> closeBoxes() async {
    try {
      await Hive.close();
      _logger.i('Hive boxes closed');
    } catch (e) {
      _logger.e('Error closing Hive boxes', error: e);
      rethrow;
    }
  }
}
