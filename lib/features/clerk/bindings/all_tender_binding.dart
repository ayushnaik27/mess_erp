import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/tender_controller.dart';

class AllTenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TenderController>(() => TenderController());
  }
}
