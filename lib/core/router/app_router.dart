import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/features/clerk/bindings/all_tender_binding.dart';
import 'package:mess_erp/features/clerk/bindings/enrollment_request_bindings.dart';
import 'package:mess_erp/features/clerk/bindings/monthly_report_binding.dart';
import 'package:mess_erp/features/clerk/bindings/open_tender_binding.dart';
import 'package:mess_erp/features/clerk/views/enrollment_request_screen.dart';
import 'package:mess_erp/committee/assigned_grievances_screen.dart';
import 'package:mess_erp/features/auth/bindings/auth_bindings.dart';
import 'package:mess_erp/features/auth/views/login_screen.dart';
import 'package:mess_erp/features/auth/views/student_register.dart';
import 'package:mess_erp/features/clerk/bindings/clerk_dashboard_binding.dart';
import 'package:mess_erp/features/clerk/views/clerk_dashboard_screen.dart';
import 'package:mess_erp/features/clerk/views/monthly_report_screen.dart';
import 'package:mess_erp/features/student/bindings/extra_items_binding.dart';
import 'package:mess_erp/features/student/bindings/student_dashboard_binding.dart';
import 'package:mess_erp/features/student/views/request_extra_items_screen.dart';
import 'package:mess_erp/features/student/views/student_dashboard.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/file_grievance_screen.dart';
import 'package:mess_erp/student/mess_bill_screen.dart';
import 'package:mess_erp/student/qr_scanner_screen.dart';
import 'package:mess_erp/student/track_leaves_screen.dart';

import '../../features/clerk/views/all_tender_screen.dart';
import '../../features/clerk/views/open_tender_screen.dart';

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

  // Add new routes for clerk navigation
  static const String monthlyReportScreen = '/monthly-report-screen';
  static const String openTender = '/open-tender';
  static const String allTenders = '/all-tenders';
  static const String enrollmentRequests = '/enrollment-requests';
  static const String assignedGrievances = '/assigned-grievances';
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

    GetPage(
      name: AppRoutes.clerkDashboard,
      page: () => ClerkDashboardScreen(),
      binding: ClerkDashboardBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.monthlyReportScreen,
      page: () => const MonthlyReportScreen(),
      binding: MonthlyReportBinding(),
    ),
    GetPage(
      name: AppRoutes.openTender,
      page: () => OpenTenderScreen(),
      binding: OpenTenderBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.allTenders,
      page: () => const AllTendersScreen(),
      binding: AllTenderBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.enrollmentRequests,
      page: () => const EnrollmentRequestScreen(),
      binding: EnrollmentRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.assignedGrievances,
      page: () {
        final args = Get.arguments;
        final userType = args?['userType'] ?? 'clerk';
        return AssignedGrievancesScreen(userType: userType);
      },
      // binding: AssignedGrievancesBinding(),
      transition: Transition.rightToLeft,
    ),
  ];

  static void navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  static void navigateToRegister() {
    Get.toNamed(AppRoutes.studentRegistration);
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
