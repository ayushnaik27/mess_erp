import 'dart:developer' as developer;

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  static const String _tag = "MESS_ERP";
  static bool enableLogs = true;

  void d(String message) {
    if (enableLogs) {
      developer.log('[$_tag] $message', name: 'DEBUG');
    }
  }

  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    if (enableLogs) {
      developer.log('[$_tag] $message',
          name: 'ERROR', error: error, stackTrace: stackTrace);
    }
  }

  void i(String message) {
    if (enableLogs) {
      developer.log('[$_tag] $message', name: 'INFO');
    }
  }
}
