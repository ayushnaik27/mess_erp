import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/features/auth/bindings/auth_bindings.dart';
import 'package:mess_erp/features/auth/views/login_screen.dart';
import 'package:mess_erp/features/auth/views/student_register.dart';
import 'package:mess_erp/features/student/bindings/extra_items_binding.dart';
import 'package:mess_erp/features/student/bindings/student_dashboard_binding.dart';
import 'package:mess_erp/features/student/views/request_extra_items_screen.dart';
import 'package:mess_erp/features/student/views/student_dashboard.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/file_grievance_screen.dart';
import 'package:mess_erp/student/mess_bill_screen.dart';
import 'package:mess_erp/student/qr_scanner_screen.dart';
import 'package:mess_erp/student/track_leaves_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const studentRegistration = '/student-registration';

  static const studentDashboard = '/student-dashboard';
  static const clerkDashboard = '/clerk-dashboard';
  static const managerDashboard = '/manager-dashboard';
  static const muneemDashboard = '/muneem-dashboard';
  static const committeeDashboard = '/committee-dashboard';

  // Student Routes
  static const qrScanner = '/student/qr-scanner';
  static const messBill = '/student/mess-bill';
  static const requestExtraItems = '/student/request-extra-items';
  static const applyLeave = '/student/apply-leave';
  static const trackLeaves = '/student/track-leaves';
  static const fileGrievance = '/student/file-grievance';
  static const trackComplaints = '/student/track-complaints';
}

class AppRouter {
  static final List<GetPage> routes = [
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
    GetPage(
      name: AppRoutes.studentDashboard,
      page: () => const StudentDashboardScreen(),
      binding: StudentDashboardBinding(),
      transition: Transition.fadeIn,
    ),

    // New student-related routes
    GetPage(
      name: AppRoutes.qrScanner,
      page: () {
        final args = Get.arguments;
        final rollNumber = args?['rollNumber'] ?? '';
        return QRScannerScreen(rollNumber: rollNumber);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.messBill,
      page: () {
        final args = Get.arguments;
        final studentId = args?['studentId'] ?? '';
        return MessBillScreen(studentId: studentId);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.requestExtraItems,
      page: () {
        final args = Get.arguments;
        final rollNumber = args?['rollNumber'] ?? '';
        return RequestExtraItemsScreen(rollNumber: rollNumber);
      },
      binding: ExtraItemsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.applyLeave,
      page: () => const ApplyLeaveScreen(),
      // binding: LeaveBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.trackLeaves,
      page: () => const TrackLeavesScreen(
        studentRollNumber: '',
      ),
      // binding: LeaveBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.fileGrievance,
      page: () => const FileGrievanceScreen(),
      // binding: GrievanceBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.trackLeaves,
      page: () {
        final args = Get.arguments;
        final rollNumber = args?['rollNumber'] ?? '';
        return TrackLeavesScreen(studentRollNumber: rollNumber);
      },
      transition: Transition.rightToLeft,
    ),

    // Admin dashboard routes
    // Add admin dashboard routes here
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
