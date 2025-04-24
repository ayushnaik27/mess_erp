import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/controllers/generate_voucher_controller.dart';

class GenerateVoucherBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure auth service is available
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    // Register the controller with dependencies
    Get.lazyPut<GenerateVoucherController>(() => GenerateVoucherController(
          authService: Get.find<AuthPersistenceService>(),
        ));
  }
}
