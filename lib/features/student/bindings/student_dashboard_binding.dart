import 'package:get/get.dart';
import 'package:mess_erp/features/student/controllers/student_dashboard_controller.dart';

class StudentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentDashboardController>(() => StudentDashboardController());
  }
}
