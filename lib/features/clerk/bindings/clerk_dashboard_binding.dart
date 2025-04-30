import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/clerk_dashboard_controller.dart';
import 'package:mess_erp/features/clerk/controllers/clerk_sheet_controller.dart';

class ClerkDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClerkDashboardController>(() => ClerkDashboardController());
    Get.put<ClerkDialogController>(ClerkDialogController(), permanent: true);
  }
}
