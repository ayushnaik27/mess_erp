import 'package:get/get.dart';
import 'package:mess_erp/features/student/controllers/extra_items_controller.dart';

class ExtraItemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExtraItemsController>(() => ExtraItemsController());
  }
}
