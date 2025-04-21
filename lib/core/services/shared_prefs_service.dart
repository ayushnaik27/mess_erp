import 'package:shared_preferences/shared_preferences.dart';
import 'package:mess_erp/core/constants/storage_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPreferences? _preferences;
  final AppLogger _logger = AppLogger();

  SharedPrefsService._();

  static Future<SharedPrefsService> getInstance() async {
    _instance ??= SharedPrefsService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> setIsLoggedIn(bool value) async {
    return await _preferences!
        .setBool(StorageConstants.prefKeyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _preferences!.getBool(StorageConstants.prefKeyIsLoggedIn) ?? false;
  }

  Future<bool> setUserId(String userId) async {
    return await _preferences!
        .setString(StorageConstants.prefKeyUserId, userId);
  }

  String? getUserId() {
    return _preferences!.getString(StorageConstants.prefKeyUserId);
  }

  Future<bool> setUserRole(String role) async {
    return await _preferences!
        .setString(StorageConstants.prefKeyUserRole, role);
  }

  String? getUserRole() {
    return _preferences!.getString(StorageConstants.prefKeyUserRole);
  }

  Future<bool> setAuthToken(String token) async {
    return await _preferences!
        .setString(StorageConstants.prefKeyAuthToken, token);
  }

  String? getAuthToken() {
    return _preferences!.getString(StorageConstants.prefKeyAuthToken);
  }

  Future<bool> setLastLoginTime(DateTime time) async {
    return await _preferences!.setInt(
        StorageConstants.prefKeyLastLoginTime, time.millisecondsSinceEpoch);
  }

  DateTime? getLastLoginTime() {
    final timestamp =
        _preferences!.getInt(StorageConstants.prefKeyLastLoginTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> clearAuthData() async {
    try {
      await _preferences!.remove(StorageConstants.prefKeyIsLoggedIn);
      await _preferences!.remove(StorageConstants.prefKeyUserId);
      await _preferences!.remove(StorageConstants.prefKeyUserRole);
      await _preferences!.remove(StorageConstants.prefKeyAuthToken);
      await _preferences!.remove(StorageConstants.prefKeyLastLoginTime);
      return true;
    } catch (e) {
      _logger.e('Error clearing SharedPreferences', error: e);
      return false;
    }
  }

  // App Settings
  Future<bool> setTheme(String theme) async {
    return await _preferences!
        .setString(StorageConstants.prefKeyAppTheme, theme);
  }

  String getTheme() {
    return _preferences!.getString(StorageConstants.prefKeyAppTheme) ?? 'light';
  }

  Future<bool> setLanguage(String language) async {
    return await _preferences!
        .setString(StorageConstants.prefKeyAppLanguage, language);
  }

  String getLanguage() {
    return _preferences!.getString(StorageConstants.prefKeyAppLanguage) ?? 'en';
  }
}
