import 'package:get/get.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_persistence_service.dart';
import 'package:mess_erp/core/utils/logger.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString hostelId = ''.obs;
  final AppLogger _logger = AppLogger();

  AuthPersistenceService? _authPersistence;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('Initializing UserService');
      _authPersistence = await AuthPersistenceService.getInstance();
      await loadCurrentUser();
      _isInitialized = true;
      _logger.i('UserService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing UserService', error: e);
    }
  }

  Future<User?> loadCurrentUser() async {
    try {
      // Make sure auth persistence is initialized
      if (_authPersistence == null) {
        _logger.w('Auth persistence not initialized yet, initializing now');
        _authPersistence = await AuthPersistenceService.getInstance();
      }

      final user = await _authPersistence!.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        hostelId.value = user.hostelId;
        _logger.i('User loaded: ${user.name}, Hostel: ${hostelId.value}');
      }
      return user;
    } catch (e) {
      _logger.e('Error loading user', error: e);
      return null;
    }
  }

  Future<void> updateCurrentUser(User user) async {
    _authPersistence ??= await AuthPersistenceService.getInstance();

    await _authPersistence!.persistUserLogin(user);
    currentUser.value = user;
    hostelId.value = user.hostelId;
  }

  String getCurrentHostelId() {
    if (hostelId.value.isNotEmpty) {
      return hostelId.value;
    }

    // Try to get from current user if not set
    if (currentUser.value?.hostelId != null &&
        currentUser.value!.hostelId.isNotEmpty) {
      hostelId.value = currentUser.value!.hostelId;
      return hostelId.value;
    }

    _logger.w('No hostel ID available');
    return '';
  }

  bool hasValidHostelId() {
    return hostelId.value.isNotEmpty ||
        (currentUser.value?.hostelId != null &&
            currentUser.value!.hostelId.isNotEmpty);
  }

  void clear() {
    currentUser.value = null;
    hostelId.value = '';
  }

  // Add initialize method that can be called from outside
  Future<UserService> init() async {
    await _initialize();
    return this;
  }
}
