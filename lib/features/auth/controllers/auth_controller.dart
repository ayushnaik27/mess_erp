import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/services/auth_service.dart';
import 'package:mess_erp/providers/itemListProvider.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/providers/vendor_name_provider.dart';
import 'package:provider/provider.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final AppLogger _logger = AppLogger();

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = RxString('');
  final RxBool _isAdmin = false.obs;
  final RxString _selectedRole = 'Select Role'.obs;

  bool get isLoading => _isLoading.value;
  String? get errorMessage =>
      _errorMessage.value.isEmpty ? null : _errorMessage.value;
  bool get isAdmin => _isAdmin.value;
  String get selectedRole => _selectedRole.value;

  void setAdminMode(bool value) {
    _isAdmin.value = value;
    _errorMessage.value = '';
  }

  void setSelectedRole(String role) {
    _selectedRole.value = role;
  }

  void resetError() {
    _errorMessage.value = '';
  }

  Future<bool> login({
    required BuildContext context,
    String? username,
    required String password,
  }) async {
    if (_isAdmin.value && _selectedRole.value == 'Select Role') {
      _errorMessage.value = 'Please select a role';
      return false;
    }

    if (password.isEmpty) {
      _errorMessage.value = 'Please enter password';
      return false;
    }

    if (!_isAdmin.value && (username == null || username.isEmpty)) {
      _errorMessage.value = 'Please enter username';
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
        if (_isAdmin.value) {
          final adminUsername = result['data']['username'];
          await _loadAdminData(context, adminUsername);

          if (!context.mounted) return false;

          Get.toNamed(
            '/${_selectedRole.value.toLowerCase()}Dashboard',
            arguments: {'email': adminUsername},
          );
        } else {
          await Provider.of<UserProvider>(context, listen: false)
              .fetchUserDetails(username!, role: 'student');

          if (!context.mounted) return false;

          Get.offAllNamed(
            AppRoutes.studentDashboard,
            arguments: {'rollNumber': username},
          );
        }

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

  Future<void> _loadAdminData(
      BuildContext context, String adminUsername) async {
    // During transition, we still need to use Provider for some parts
    await Provider.of<UserProvider>(context, listen: false).fetchUserDetails(
        adminUsername,
        admin: true,
        role: _selectedRole.value);
    await Provider.of<VendorNameProvider>(context, listen: false)
        .fetchAndSetVendorNames();
    await Provider.of<ItemListProvider>(context, listen: false)
        .fetchAndSetItems();
  }

  Future<Map<String, dynamic>> register({
    required String rollNumber,
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _authService.registerStudent(
        rollNumber: rollNumber,
        name: name,
        email: email,
        password: password,
      );

      _isLoading.value = false;
      if (!result['success']) {
        _errorMessage.value = result['message'];
      }
      return result;
    } catch (e, stack) {
      _logger.e('Register controller error', error: e, stackTrace: stack);
      _isLoading.value = false;
      _errorMessage.value = 'An unexpected error occurred';
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }
}
