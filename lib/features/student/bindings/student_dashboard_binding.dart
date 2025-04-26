import 'package:get/get.dart';
import 'package:mess_erp/features/student/controllers/student_dashboard_controller.dart';
import 'package:mess_erp/features/student/services/leave_service.dart';

class StudentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentDashboardController>(() => StudentDashboardController());
    Get.lazyPut(() => LeaveService(), fenix: true);
  }
}
