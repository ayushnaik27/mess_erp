import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess_erp/clerk/mess_bill_provider.dart';
import 'package:mess_erp/clerk/monthly_report_provider.dart';
import 'package:mess_erp/core/router/app_router.dart';
import 'package:mess_erp/core/theme/app_theme.dart';
import 'package:mess_erp/core/utils/dependency_injection.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/auth/bindings/auth_bindings.dart';
import 'package:mess_erp/features/auth/views/login_screen.dart';
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

  AppLogger().i('App started');

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
      ),
    );
  }
}
