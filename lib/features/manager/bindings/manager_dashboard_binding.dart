import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/controllers/manager_dashboard_controller.dart';

class ManagerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    Get.lazyPut<ManagerDashboardController>(() => ManagerDashboardController(
          authService: Get.find<AuthPersistenceService>(),
        ));
  }
}
