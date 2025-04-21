import 'package:get/get.dart';

import 'logger.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.put<AppLogger>(AppLogger(), permanent: true);
  }
}
