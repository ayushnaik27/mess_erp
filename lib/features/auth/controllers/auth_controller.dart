import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/constants/hostel_constants.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/models/user_model.dart';
import 'package:mess_erp/features/auth/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final AppLogger _logger = AppLogger();

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = RxString('');
  final RxBool _isAdmin = false.obs;
  final RxString _selectedRole = AppStrings.selectRole.obs;
  final RxString _selectedHostel = RxString('');
  final RxBool _isInitialized = false.obs;

  bool get isLoading => _isLoading.value;
  String? get errorMessage =>
      _errorMessage.value.isEmpty ? null : _errorMessage.value;
  bool get isAdmin => _isAdmin.value;
  String get selectedRole => _selectedRole.value;
  String get selectedHostel => _selectedHostel.value;
  List<String> get hostels => HostelConstants.allHostels;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _authService.init();
      _isInitialized.value = true;

      // Now we can check auth state
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _navigateBasedOnRole(user.role, user.id);
        }
      }
    } catch (e) {
      _logger.e('Failed to initialize AuthController', error: e);
    }
  }

  void setAdminMode(bool value) {
    _isAdmin.value = value;
    _errorMessage.value = '';
  }

  void setSelectedRole(String role) {
    _selectedRole.value = role;
  }

  void setSelectedHostel(String hostel) {
    _selectedHostel.value = hostel;
  }

  void resetError() {
    _errorMessage.value = '';
  }

  Future<bool> login({
    required BuildContext context,
    String? username,
    required String password,
  }) async {
    // Validation
    if (_isAdmin.value && _selectedRole.value == AppStrings.selectRole) {
      _errorMessage.value = AppStrings.selectRoleError;
      return false;
    }

    if (password.isEmpty) {
      _errorMessage.value = AppStrings.enterPasswordError;
      return false;
    }

    if (!_isAdmin.value && (username == null || username.isEmpty)) {
      _errorMessage.value = AppStrings.enterUsernameError;
      return false;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      Map<String, dynamic> result;
      if (_isAdmin.value) {
        result = await _authService.adminLogin(
          role: _selectedRole.value,
          password: password,
        );
      } else {
        result = await _authService.studentLogin(
          username: username!,
          password: password,
        );
      }

      _isLoading.value = false;

      if (result['success']) {
        final user = result['data']['user'] as User;
        _navigateBasedOnRole(user.role, user.id);
        return true;
      } else {
        _errorMessage.value = result['message'];
        return false;
      }
    } catch (e, stack) {
      _logger.e('Login controller error', error: e, stackTrace: stack);
      _isLoading.value = false;
      _errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  Future<bool> register({
    required String rollNumber,
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
  }) async {
    // Validation
    if (rollNumber.isEmpty) {
      _errorMessage.value = 'Please enter roll number';
      return false;
    }

    if (name.isEmpty) {
      _errorMessage.value = 'Please enter your name';
      return false;
    }

    if (email.isEmpty) {
      _errorMessage.value = 'Please enter your email';
      return false;
    }

    if (password.isEmpty) {
      _errorMessage.value = 'Please enter a password';
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage.value = 'Passwords do not match';
      return false;
    }

    if (_selectedHostel.value.isEmpty) {
      _errorMessage.value = 'Please select your hostel';
      return false;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _authService.registerStudent(
        rollNumber: rollNumber,
        name: name,
        email: email,
        password: password,
        hostel: _selectedHostel.value,
        phoneNumber: phoneNumber,
      );

      _isLoading.value = false;

      if (result['success']) {
        Get.snackbar(
          'Success',
          'Registration successful! Please wait for admin approval.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.login);
        return true;
      } else {
        _errorMessage.value = result['message'];
        return false;
      }
    } catch (e, stack) {
      _logger.e('Register controller error', error: e, stackTrace: stack);
      _isLoading.value = false;
      _errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading.value = true;
    try {
      final success = await _authService.logout();
      _isLoading.value = false;

      if (success) {
        Get.offAllNamed(AppRoutes.login);
      }

      return success;
    } catch (e) {
      _logger.e('Logout error', error: e);
      _isLoading.value = false;
      return false;
    }
  }

  void _navigateBasedOnRole(String role, String userId) {
    switch (role.toLowerCase()) {
      case 'student':
        Get.offAllNamed(
          AppRoutes.studentDashboard,
          arguments: {'rollNumber': userId},
        );
        break;
      case 'clerk':
      case 'manager':
      case 'muneem':
      case 'committee':
        Get.offAllNamed(
          '/${role.toLowerCase()}Dashboard',
          arguments: {'username': userId},
        );
        break;
      default:
        _logger.w('Unknown role: $role');
        Get.offAllNamed(AppRoutes.login);
    }
  }
}
