import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/controllers/enrollment_request_controller.dart';

class EnrollmentRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnrollmentRequestController>(
        () => EnrollmentRequestController());
  }
}
