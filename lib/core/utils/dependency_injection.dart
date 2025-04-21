import 'package:get/get.dart';
import 'package:mess_erp/core/services/hive_service.dart';
import 'package:mess_erp/core/services/shared_prefs_service.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';

import 'logger.dart';

class DependencyInjection {
  static Future<void> init() async {
    final logger = AppLogger();

    Get.put<AppLogger>(AppLogger(), permanent: true);

    await HiveService.getInstance();
    logger.i('Hive service initialized');

    await SharedPrefsService.getInstance();
    logger.i('SharedPrefs service initialized');

    await AuthPersistenceService.getInstance();
    logger.i('Auth persistence service initialized');
  }
}
