import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:mess_erp/auth/login_screen.dart';
import 'package:mess_erp/clerk/dashboard.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/clerk/monthly_report_provider.dart';
import 'package:mess_erp/clerk/monthly_report_screen.dart';
import 'package:mess_erp/committee/add_announcements_screen.dart';
import 'package:mess_erp/committee/all_grievances_screen.dart';
import 'package:mess_erp/committee/bill_screen.dart';
import 'package:mess_erp/committee/dashboard.dart';
import 'package:mess_erp/committee/extra_items_screen.dart';
import 'package:mess_erp/firebase_options.dart';
import 'package:mess_erp/manager/dashboard.dart';
import 'package:mess_erp/manager/generate_voucher_screen.dart';
import 'package:mess_erp/manager/issue_stock_screen.dart';
import 'package:mess_erp/manager/previous_vouchers_screen.dart';
import 'package:mess_erp/manager/receive_stock_screen.dart';
import 'package:mess_erp/muneem/approve_extra_items_screen.dart';
import 'package:mess_erp/muneem/dashboard.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
=======
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/theme/app_theme.dart';
import 'package:mess_erp/core/utils/dependency_injection.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/bindings/auth_bindings.dart';
import 'package:mess_erp/features/auth/views/login_screen.dart';
import 'package:mess_erp/firebase_options.dart';
// import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
import 'package:mess_erp/providers/extra_item_provider.dart';
import 'package:mess_erp/providers/itemListProvider.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:mess_erp/providers/tender_provider.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/providers/voucher_provider.dart';
<<<<<<< HEAD
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/dashboard.dart';
import 'package:mess_erp/student/request_extra_items_screen.dart';
import 'package:mess_erp/student/track_complaints_screen.dart';
=======
>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
import 'package:provider/provider.dart';

import 'providers/grievance_provider.dart';
import 'providers/vendor_name_provider.dart';
<<<<<<< HEAD
import 'student/file_grievance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
=======

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = AppLogger();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleFonts.pendingFonts([
    GoogleFonts.plusJakartaSans(),
  ]);
  await DependencyInjection.init();
  logger.i('Dependency injection initialized');

  AppLogger().i('App started');

>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExtraItemsProvider()),
        ChangeNotifierProvider(create: (_) => VendorNameProvider()),
<<<<<<< HEAD
        ChangeNotifierProvider(create: (_) => BillsOfPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyReportProvider()),
=======
        // ChangeNotifierProvider(create: (_) => BillsOfPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
        ChangeNotifierProvider(create: (_) => MessBillProvider()),
        ChangeNotifierProvider(create: (_) => GrievanceProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
        ChangeNotifierProvider(create: (_) => ItemListProvider()),
      ],
<<<<<<< HEAD
      child: MaterialApp(
        title: 'Mess ERP',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color.fromRGBO(249, 214, 137, 1),
            secondary: Color.fromRGBO(224, 167, 94, 1),
            tertiary: Color.fromRGBO(151, 49, 49, 1),
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            titleMedium: TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            bodySmall: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            labelSmall: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            displayLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 54, 40, 40),
            ),
            displayMedium: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 54, 40, 40),
              fontWeight: FontWeight.w700,
            ),
            displaySmall: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 54, 40, 40),
            ),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(224, 167, 94, 1),
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.red,
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        routes: {
          StudentDashboardScreen.routeName: (context) =>
              const StudentDashboardScreen(),
          ClerkDashboardScreen.routeName: (context) =>
              const ClerkDashboardScreen(),
          ManagerDashboardScreen.routeName: (context) =>
              const ManagerDashboardScreen(),
          CommitteeDashboardScreen.routeName: (context) =>
              const CommitteeDashboardScreen(),
          MuneemDashboardScreen.routeName: (context) =>
              const MuneemDashboardScreen(),
          AddAnnouncementScreen.routeName: (context) => AddAnnouncementScreen(),
          RequestExtraItemsScreen.routeName: (context) =>
              const RequestExtraItemsScreen(),
          ExtraItemsScreen.routeName: (context) => ExtraItemsScreen(),
          ReceiveStockScreen.routeName: (context) => ReceiveStockScreen(),
          BillsScreen.routeName: (context) => const BillsScreen(),
          IssueStockScreen.routeName: (context) => IssueStockScreen(),
          GenerateVoucherScreen.routeName: (context) => GenerateVoucherScreen(),
          PreviousVouchersScreen.routeName: (context) =>
              const PreviousVouchersScreen(),
          ApproveExtraItemsScreen.routeName: (context) =>
              ApproveExtraItemsScreen(),
          ApplyLeaveScreen.routeName: (context) => const ApplyLeaveScreen(),
          MonthlyReportScreen.routeName: (context) =>
              const MonthlyReportScreen(),
          FileGrievanceScreen.routeName: (context) => FileGrievanceScreen(),
          TrackComplaintScreen.routeName: (context) =>
              const TrackComplaintScreen(),
          AllGrievancesScreen.routeName: (context) =>
              const AllGrievancesScreen(),
        },
        home: const LoginScreen(),
=======
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mess ERP',
        theme: AppTheme.lightTheme,
        initialBinding: AuthBinding(),
        home: const LoginScreen(),
        getPages: AppRouter.routes,
        unknownRoute: GetPage(
          name: '/not-found',
          page: () => _buildNotFoundPage(),
        ),
      ),
    );
  }

  Widget _buildNotFoundPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The requested route does not exist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
>>>>>>> 701f01e7b22ea1c616895b5da016062859e05f15
      ),
    );
  }
}
