import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mess_erp/auth/login_screen.dart';
import 'package:mess_erp/auth/student_register.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Student routes
      GoRoute(
        path: '/student-registration',
        name: 'student_registration',
        builder: (context, state) => const StudentRegisterScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri.path}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}
