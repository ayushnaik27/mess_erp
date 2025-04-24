import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/manager/controllers/add_item_controller.dart';

class AddItemBinding extends Bindings {
  final Function(ItemEntry)? onAddItem;

  AddItemBinding({this.onAddItem});

  @override
  void dependencies() {
    // Make sure auth service is available
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(() async {
        return await AuthPersistenceService.getInstance();
      }, permanent: true);
    }

    // Register the controller with dependencies
    Get.put<AddItemController>(AddItemController(
      authService: Get.find<AuthPersistenceService>(),
      onAddItem: onAddItem,
    ));
  }
}
