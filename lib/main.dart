import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:mess_erp/providers/extra_item_provider.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:mess_erp/providers/tender_provider.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:mess_erp/providers/vendor_provider.dart';
import 'package:mess_erp/providers/voucher_provider.dart';
import 'package:mess_erp/student/apply_leave_screen.dart';
import 'package:mess_erp/student/dashboard.dart';
import 'package:mess_erp/student/request_extra_items_screen.dart';
import 'package:mess_erp/student/track_complaints_screen.dart';
import 'package:provider/provider.dart';

import 'providers/grievance_provider.dart';
import 'student/file_grievance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExtraItemsProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BillsOfPurchaseProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyReportProvider()),
        ChangeNotifierProvider(create: (_) => MessBillProvider()),
        ChangeNotifierProvider(create: (_) => GrievanceProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF1E5D1),
            secondary: Color(0xFFDBB5B5),
            tertiary: Color(0xFF987070),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
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
      ),
    );
  }
}
