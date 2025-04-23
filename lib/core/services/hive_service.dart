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

  final Map<String, bool> _openBoxes = {};

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

      // Register adapters only once
      if (!Hive.isAdapterRegistered(0)) {
        // Use the adapter ID you've defined
        Hive.registerAdapter(UserAdapter());
      }

      // Open essential boxes and track them
      await _openBox(StorageConstants.userBox);
      await _openBox(StorageConstants.settingsBox);
      await _openBox(StorageConstants.cacheBox);

      _isInitialized = true;
      _logger.i('Hive initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Hive', error: e);
      _isInitialized = false;
    }
  }

  Future<Box> _openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      final box = await Hive.openBox(boxName);
      _openBoxes[boxName] = true;
      return box;
    }
    return Hive.box(boxName);
  }

  Future<Box> _ensureBox(String boxName) async {
    if (!_isInitialized) {
      await _initHive();
    }

    return await _openBox(boxName);
  }

  Future<void> saveUser(User user) async {
    try {
      final box = await _ensureBox(StorageConstants.userBox);
      await box.put(StorageConstants.hiveKeyUserData, user);
      _logger.i('User saved to Hive: ${user.name}');
    } catch (e) {
      _logger.e('Error saving user to Hive', error: e);
      rethrow;
    }
  }

  Future<User?> getUser() async {
    try {
      final box = await _ensureBox(StorageConstants.userBox);
      return box.get(StorageConstants.hiveKeyUserData);
    } catch (e) {
      _logger.e('Error getting user from Hive', error: e);
      return null;
    }
  }

  Future<void> deleteUser() async {
    try {
      final box = await _ensureBox(StorageConstants.userBox);
      await box.delete(StorageConstants.hiveKeyUserData);
      _logger.i('User deleted from Hive');
    } catch (e) {
      _logger.e('Error deleting user from Hive', error: e);
      rethrow;
    }
  }

  Future<void> saveData(String boxName, String key, dynamic value) async {
    try {
      final box = await _ensureBox(boxName);

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

  Future<dynamic> getData(String boxName, String key) async {
    try {
      final box = await _ensureBox(boxName);
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
      final box = await _ensureBox(boxName);
      await box.delete(key);
    } catch (e) {
      _logger.e('Error deleting data from Hive', error: e);
      rethrow;
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = await _ensureBox(boxName);
      await box.clear();
    } catch (e) {
      _logger.e('Error clearing Hive box', error: e);
      rethrow;
    }
  }

  Future<void> closeBoxes() async {
    try {
      for (final boxName in _openBoxes.keys) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
      }
      _openBoxes.clear();
      _logger.i('Hive boxes closed');
    } catch (e) {
      _logger.e('Error closing Hive boxes', error: e);
      rethrow;
    }
  }
}
