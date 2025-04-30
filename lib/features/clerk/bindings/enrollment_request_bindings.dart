import 'package:get/get.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/features/clerk/controllers/enrollment_request_controller.dart';

class EnrollmentRequestBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthPersistenceService>()) {
      Get.putAsync<AuthPersistenceService>(
        () => AuthPersistenceService.getInstance(),
        permanent: true,
      );
    }

    Get.create<EnrollmentRequestController>(() {
      final persistenceService = Get.find<AuthPersistenceService>();
      return EnrollmentRequestController(
          persistenceService: persistenceService);
    });
  }
}
