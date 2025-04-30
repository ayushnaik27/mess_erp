import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/clerk/controllers/tender_controller.dart';

class AllTenderBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    Get.lazyPut<TenderController>(() => TenderController(
          persistenceService: Get.find<AuthPersistenceService>(),
        ));
  }
}
