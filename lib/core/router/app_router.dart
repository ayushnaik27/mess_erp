import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mess_erp/features/committee/controllers/committee_dashboard_controller.dart';
import 'package:mess_erp/features/committee/controllers/mess_menu_controller.dart';
import 'package:mess_erp/features/committee/presentation/committee_dashboard.dart';
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
import 'package:mess_erp/features/committee/presentation/mess_menu_screen.dart';
import 'package:mess_erp/features/manager/bindings/add_item_binding.dart';
import 'package:mess_erp/features/manager/bindings/generate_voucher_binding.dart';
import 'package:mess_erp/features/manager/bindings/issue_stock_binding.dart';
import 'package:mess_erp/features/manager/bindings/manager_dashboard_binding.dart';
import 'package:mess_erp/features/manager/presentation/add_items_screen.dart';
import 'package:mess_erp/features/manager/presentation/generate_voucher_screen.dart';
import 'package:mess_erp/features/manager/presentation/issue_stock_screen.dart';
import 'package:mess_erp/features/muneem/bindings/muneem_dashboard_binding.dart';
import 'package:mess_erp/features/muneem/presentation/muneen_dashboard.dart';
import 'package:mess_erp/features/student/bindings/extra_items_binding.dart';
import 'package:mess_erp/features/student/bindings/student_dashboard_binding.dart';
import 'package:mess_erp/features/student/views/request_extra_items_screen.dart';
import 'package:mess_erp/features/student/views/student_dashboard.dart';
import 'package:mess_erp/features/manager/presentation/manager_dashboard.dart';
import 'package:mess_erp/features/student/views/apply_leave_screen.dart';
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

  // Manager Routes
  static const generateVoucher = '/generate-voucher';
  static const issueStock = '/issue-stock';

  // Add new routes for clerk navigation
  static const String monthlyReportScreen = '/monthly-report-screen';
  static const String openTender = '/open-tender';
  static const String allTenders = '/all-tenders';
  static const String enrollmentRequests = '/enrollment-requests';
  static const String assignedGrievances = '/assigned-grievances';
  static const String messMenuOperations = '/mess-menu-operations';
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
      name: AppRoutes.managerDashboard,
      page: () => const ManagerDashboardScreen(),
      binding: ManagerDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.managerDashboard,
      page: () => const AddItemScreen(),
      binding: AddItemBinding(),
    ),

    GetPage(
      name: AppRoutes.generateVoucher,
      page: () => const GenerateVoucherScreen(),
      binding: GenerateVoucherBinding(),
    ),
    GetPage(
      name: AppRoutes.issueStock,
      page: () => const IssueStockScreen(),
      binding: IssueStockBinding(),
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

    // Muneem Dashboard
    GetPage(
      name: AppRoutes.muneemDashboard,
      page: () => const MuneemDashboardScreen(),
      binding: MuneemDashboardBinding(),
      transition: Transition.fadeIn,
    ),

    // committee dashboard

    GetPage(
      name: AppRoutes.committeeDashboard,
      page: () => const CommitteeDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CommitteeDashboardController>(
            () => CommitteeDashboardController());
      }),
    ),

    GetPage(
      name: AppRoutes.messMenuOperations,
      page: () => const MessMenuScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MessMenuController>(() => MessMenuController());
      }),
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
