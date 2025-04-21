import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mess_erp/features/auth/views/student_register.dart';
import 'package:mess_erp/core/constants/app_assets.dart';
import 'package:mess_erp/core/constants/app_strings.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.resetError();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggleLoginMode() {
    authController.setAdminMode(!authController.isAdmin);
  }

  Future<void> _login() async {
    final success = await authController.login(
      context: context,
      username: usernameController.text,
      password: passwordController.text,
    );

    if (success && mounted) {
      passwordController.clear();
      if (!authController.isAdmin) {
        usernameController.clear();
      }
    }
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'Message',
      message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      borderRadius: 8,
      margin: EdgeInsets.all(8.r),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        return authController.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.h),

                            // Logo and header
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 80.h,
                                    width: 80.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        AppAssets.logoPath,
                                        height: 60.h,
                                        width: 60.w,
                                      ),
                                    ),
                                  ).animate().fadeIn(duration: 600.ms).scale(
                                        begin: const Offset(0.8, 0.8),
                                        end: const Offset(1, 1),
                                        duration: 500.ms,
                                        curve: Curves.easeOutQuad,
                                      ),
                                  SizedBox(height: 24.h),
                                  Text(
                                    authController.isAdmin
                                        ? AppStrings.adminLogin
                                        : AppStrings.welcome,
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: 200.ms, duration: 600.ms)
                                      .moveY(
                                          begin: 20,
                                          end: 0,
                                          delay: 200.ms,
                                          duration: 600.ms,
                                          curve: Curves.easeOutQuad),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Sign in to access your account',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: 300.ms, duration: 600.ms)
                                      .moveY(
                                          begin: 20,
                                          end: 0,
                                          delay: 300.ms,
                                          duration: 600.ms,
                                          curve: Curves.easeOutQuad),
                                ],
                              ),
                            ),

                            SizedBox(height: 48.h),

                            // Tab selector
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              height: 56.h,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (authController.isAdmin)
                                          _toggleLoginMode();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: !authController.isAdmin
                                              ? Colors.white
                                              : const Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          boxShadow: !authController.isAdmin
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Student',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight:
                                                  !authController.isAdmin
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                              color: !authController.isAdmin
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!authController.isAdmin)
                                          _toggleLoginMode();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: authController.isAdmin
                                              ? Colors.white
                                              : const Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          boxShadow: authController.isAdmin
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: authController.isAdmin
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: authController.isAdmin
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms)
                                .moveY(
                                    begin: 20,
                                    end: 0,
                                    delay: 400.ms,
                                    duration: 600.ms),

                            SizedBox(height: 32.h),

                            // Form fields
                            _buildFormFields()
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 600.ms)
                                .moveY(
                                    begin: 20,
                                    end: 0,
                                    delay: 600.ms,
                                    duration: 600.ms),

                            if (authController.errorMessage != null)
                              Container(
                                margin: EdgeInsets.only(top: 16.h),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        authController.errorMessage!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .shake(delay: 200.ms, duration: 500.ms),

                            SizedBox(height: 40.h),

                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                minimumSize: Size(double.infinity, 56.h),
                              ),
                              child: Text(
                                AppStrings.loginButton,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 700.ms, duration: 600.ms)
                                .moveY(
                                    begin: 20,
                                    end: 0,
                                    delay: 700.ms,
                                    duration: 600.ms),

                            SizedBox(height: 24.h),

                            if (!authController.isAdmin)
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.newStudent,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.to(() => const RegisterScreen());
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        AppStrings.registerHere,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 600.ms),

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authController.isAdmin) ...[
          Text(
            'Select Role',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRoleDropdown(),
          SizedBox(height: 24.h),
        ],
        if (!authController.isAdmin) ...[
          Text(
            AppStrings.username,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildTextField(
            controller: usernameController,
            hintText: 'Enter your username',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 24.h),
        ],
        Text(
          AppStrings.password,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: passwordController,
          hintText: 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showSnackBar(AppStrings.forgotPasswordMessage);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.forgotPassword,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Obx(() => Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                authController.selectedRole,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: authController.selectedRole == AppStrings.selectRole
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              borderRadius: BorderRadius.circular(12.r),
              items: [
                DropdownMenuItem(
                  value: 'clerk',
                  child: Text(AppStrings.clerk),
                ),
                DropdownMenuItem(
                  value: 'manager',
                  child: Text(AppStrings.manager),
                ),
                DropdownMenuItem(
                  value: 'muneem',
                  child: Text(AppStrings.muneem),
                ),
                DropdownMenuItem(
                  value: 'committee',
                  child: Text(AppStrings.committee),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                authController.setSelectedRole(value);
              },
            ),
          ),
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20.r,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20.r,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}
