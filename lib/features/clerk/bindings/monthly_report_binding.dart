import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/monthly_report_controller.dart';

class MonthlyReportBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyReportController>(() => MonthlyReportController());
  }
}
