import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/auth/services/auth_service.dart';
import 'package:mess_erp/features/muneem/controllers/muneem_dashboard_controller.dart';

class MuneemDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
      Get.find<AuthService>().init();
    }

    Get.lazyPut<MuneemDashboardController>(() => MuneemDashboardController(
          authPersistenceService: Get.find<AuthPersistenceService>(),
          authService: Get.find<AuthService>(),
        ));
  }
}
