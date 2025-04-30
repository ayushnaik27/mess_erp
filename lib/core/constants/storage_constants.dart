class StorageConstants {
  // SharedPreferences keys
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserRole = 'user_role';
  static const String prefKeyLastLoginTime = 'last_login_time';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyTokenExpiry = 'token_expiry';
  static const String prefKeyAppTheme = 'app_theme';
  static const String prefKeyAppLanguage = 'app_language';

  // Hive box names
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';

  // Hive keys
  static const String hiveKeyUserData = 'user_data';
  static const String hiveKeyUserSettings = 'user_settings';
  static const String hiveKeyMessMenu = 'mess_menu';
  static const String hiveKeyAnnouncements = 'announcements';
}
