import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/features/auth/bindings/auth_bindings.dart';
import 'package:mess_erp/features/auth/views/login_screen.dart';
import 'package:mess_erp/features/auth/views/student_register.dart';

class AppRoutes {
  // Route names as constants for consistency
  static const login = '/login';
  static const studentRegistration = '/student-registration';

  // Dashboard routes
  static const studentDashboard = '/student-dashboard';
  static const clerkDashboard = '/clerk-dashboard';
  static const managerDashboard = '/manager-dashboard';
  static const muneemDashboard = '/muneem-dashboard';
  static const committeeDashboard = '/committee-dashboard';
}

class AppRouter {
  static final List<GetPage> routes = [
    // Auth routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.studentRegistration,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // GetPage(
    //   name: AppRoutes.studentDashboard,
    //   page: () => const StudentDashboardScreen(),
    //   binding: DashboardBinding(),
    //   transition: Transition.fadeIn,
    // ),
  ];

  static void navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  static void navigateToRegister() {
    Get.toNamed(AppRoutes.studentRegistration);
  }

  static void navigateToDashboard(String role, {String? username}) {
    switch (role.toLowerCase()) {
      case 'student':
        Get.offAllNamed(AppRoutes.studentDashboard,
            arguments: {'username': username});
        break;
      case 'clerk':
        Get.offAllNamed(AppRoutes.clerkDashboard,
            arguments: {'username': username});
        break;
      case 'manager':
        Get.offAllNamed(AppRoutes.managerDashboard,
            arguments: {'username': username});
        break;
      case 'muneem':
        Get.offAllNamed(AppRoutes.muneemDashboard,
            arguments: {'username': username});
        break;
      case 'committee':
        Get.offAllNamed(AppRoutes.committeeDashboard,
            arguments: {'username': username});
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }

  static void goBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  static Widget notFoundPage(String path) {
    return Scaffold(
      body: Center(
        child: Text(
          'Page not found: $path',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
