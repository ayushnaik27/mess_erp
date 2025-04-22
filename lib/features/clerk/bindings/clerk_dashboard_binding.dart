import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/clerk_dashboard_controller.dart';
import 'package:mess_erp/features/clerk/controllers/clerk_sheet_controller.dart';
import 'package:mess_erp/features/clerk/services/clerk_service.dart';

class ClerkDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClerkService>(() => ClerkService());
    Get.lazyPut<ClerkDashboardController>(() => ClerkDashboardController());
    Get.lazyPut<ClerkDialogController>(() => ClerkDialogController());
  }
}
