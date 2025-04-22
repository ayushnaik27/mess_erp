import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/tender_controller.dart';

class OpenTenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TenderController>(() => TenderController());
  }
}
