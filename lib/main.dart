import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/clerk/monthly_report_provider.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/theme/app_theme.dart';
import 'package:mess_erp/core/utils/dependency_injection.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/firebase_options.dart';
import 'package:mess_erp/providers/bills_of_purchase_provider.dart';
import 'package:mess_erp/providers/extra_item_provider.dart';
import 'package:mess_erp/providers/itemListProvider.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:mess_erp/providers/tender_provider.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/providers/voucher_provider.dart';
import 'package:provider/provider.dart';

import 'providers/grievance_provider.dart';
import 'providers/vendor_name_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleFonts.pendingFonts([
    GoogleFonts.plusJakartaSans(),
  ]);
  await DependencyInjection.init();

  Logger().i('App started');

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
        ChangeNotifierProvider(create: (_) => BillsOfPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyReportProvider()),
        ChangeNotifierProvider(create: (_) => MessBillProvider()),
        ChangeNotifierProvider(create: (_) => GrievanceProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
        ChangeNotifierProvider(create: (_) => ItemListProvider()),
      ],
      child: MaterialApp.router(
        title: 'Mess ERP',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        // theme: ThemeData(
        //   colorScheme: const ColorScheme.light(
        //     primary: Color.fromRGBO(249, 214, 137, 1),
        //     secondary: Color.fromRGBO(224, 167, 94, 1),
        //     tertiary: Color.fromRGBO(151, 49, 49, 1),
        //     brightness: Brightness.light,
        //   ),
        //   textTheme: const TextTheme(
        //     titleLarge: TextStyle(
        //       fontSize: 26,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //     ),
        //     titleMedium: TextStyle(
        //       fontSize: 22,
        //       color: Colors.black,
        //     ),
        //     bodyLarge: TextStyle(
        //       fontSize: 24,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //     ),
        //     bodyMedium: TextStyle(
        //       fontSize: 18,
        //       fontWeight: FontWeight.w600,
        //       color: Colors.black,
        //     ),
        //     bodySmall: TextStyle(
        //       fontSize: 14,
        //       color: Colors.black,
        //     ),
        //     labelSmall: TextStyle(
        //       fontSize: 12,
        //       color: Colors.black54,
        //     ),
        //     displayLarge: TextStyle(
        //       fontSize: 24,
        //       fontWeight: FontWeight.w700,
        //       color: Color.fromARGB(255, 54, 40, 40),
        //     ),
        //     displayMedium: TextStyle(
        //       fontSize: 18,
        //       color: Color.fromARGB(255, 54, 40, 40),
        //       fontWeight: FontWeight.w700,
        //     ),
        //     displaySmall: TextStyle(
        //       fontSize: 14,
        //       color: Color.fromARGB(255, 54, 40, 40),
        //     ),
        //   ),
        //   useMaterial3: true,
        //   appBarTheme: const AppBarTheme(
        //     backgroundColor: Color.fromRGBO(224, 167, 94, 1),
        //     titleTextStyle: TextStyle(
        //       fontSize: 24,
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black,
        //     ),
        //   ),
        //   snackBarTheme: const SnackBarThemeData(
        //     backgroundColor: Colors.red,
        //     contentTextStyle: TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
        // routes: {
        //   StudentDashboardScreen.routeName: (context) =>
        //       const StudentDashboardScreen(),
        //   ClerkDashboardScreen.routeName: (context) =>
        //       const ClerkDashboardScreen(),
        //   ManagerDashboardScreen.routeName: (context) =>
        //       const ManagerDashboardScreen(),
        //   CommitteeDashboardScreen.routeName: (context) =>
        //       const CommitteeDashboardScreen(),
        //   MuneemDashboardScreen.routeName: (context) =>
        //       const MuneemDashboardScreen(),
        //   AddAnnouncementScreen.routeName: (context) => AddAnnouncementScreen(),
        //   RequestExtraItemsScreen.routeName: (context) =>
        //       const RequestExtraItemsScreen(),
        //   ExtraItemsScreen.routeName: (context) => ExtraItemsScreen(),
        //   ReceiveStockScreen.routeName: (context) => ReceiveStockScreen(),
        //   BillsScreen.routeName: (context) => const BillsScreen(),
        //   IssueStockScreen.routeName: (context) => IssueStockScreen(),
        //   GenerateVoucherScreen.routeName: (context) => GenerateVoucherScreen(),
        //   PreviousVouchersScreen.routeName: (context) =>
        //       const PreviousVouchersScreen(),
        //   ApproveExtraItemsScreen.routeName: (context) =>
        //       ApproveExtraItemsScreen(),
        //   ApplyLeaveScreen.routeName: (context) => const ApplyLeaveScreen(),
        //   MonthlyReportScreen.routeName: (context) =>
        //       const MonthlyReportScreen(),
        //   FileGrievanceScreen.routeName: (context) => FileGrievanceScreen(),
        //   TrackComplaintScreen.routeName: (context) =>
        //       const TrackComplaintScreen(),
        //   AllGrievancesScreen.routeName: (context) =>
        //       const AllGrievancesScreen(),
        // },
        // home: const LoginScreen(),
      ),
    );
  }
}
