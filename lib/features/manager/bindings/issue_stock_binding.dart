import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/controllers/issue_stock_controller.dart';

class IssueStockBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure auth service is available
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    // Register the controller with dependencies
    Get.lazyPut<IssueStockController>(() => IssueStockController(
          authService: Get.find<AuthPersistenceService>(),
        ));
  }
}
