import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/app_assets.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';
import 'package:mess_erp/core/utils/screen_utils.dart';
import 'package:mess_erp/features/auth/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    rollNumberController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (authController.selectedHostel.isEmpty) {
      _showSnackBar('Please select your hostel', false);
      return;
    }

    final success = await authController.register(
      rollNumber: rollNumberController.text,
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      phoneNumber: null, // for later
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
          'Registration successful! Please wait for admin approval.', true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Get.back();
      });
    } else {
      _showSnackBar(
          authController.errorMessage ?? 'Registration failed', false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    Get.snackbar(
      isSuccess ? 'Success' : 'Error',
      message,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? AppColors.success : AppColors.error,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => authController.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section with animation
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  height: 70.h,
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AppAssets.logoPath,
                                      height: 50.h,
                                      width: 50.w,
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 600.ms).scale(
                                      begin: const Offset(0.8, 0.8),
                                      end: const Offset(1, 1),
                                      duration: 500.ms,
                                      curve: Curves.easeOutQuad,
                                    ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Create an Account',
                                  style: TextStyle(
                                    fontSize: 24.sp,
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
                                        duration: 600.ms),
                                SizedBox(height: 8.h),
                                Text(
                                  'Register as a new student',
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
                                        duration: 600.ms),
                              ],
                            ),
                          ),

                          // Rest of the form fields
                          SizedBox(height: 32.h),
                          _buildFormFields(),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Roll number field
        _buildFieldLabel('Roll Number')
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: rollNumberController,
          hintText: 'Enter your roll number',
          icon: Icons.badge_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your roll number';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 450.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 450.ms, duration: 400.ms),

        SizedBox(height: 20.h),

        // Name field
        _buildFieldLabel('Full Name')
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 500.ms, duration: 400.ms),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: nameController,
          hintText: 'Enter your full name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 550.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 550.ms, duration: 400.ms),

        SizedBox(height: 20.h),

        // Email field
        _buildFieldLabel('Email Address')
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 600.ms, duration: 400.ms),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: emailController,
          hintText: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 650.ms, duration: 400.ms),

        SizedBox(height: 20.h),

        // Password field
        _buildFieldLabel('Password')
            .animate()
            .fadeIn(delay: 700.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 700.ms, duration: 400.ms),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: passwordController,
          hintText: 'Create a password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword,
          toggleObscure: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 750.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 750.ms, duration: 400.ms),

        SizedBox(height: 20.h),

        // Confirm password field
        _buildFieldLabel('Confirm Password')
            .animate()
            .fadeIn(delay: 800.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 800.ms, duration: 400.ms),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm your password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          toggleObscure: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 850.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 850.ms, duration: 400.ms),

        SizedBox(height: 20.h),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: authController.selectedHostel.isEmpty
                      ? null
                      : authController.selectedHostel,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Select your hostel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  borderRadius: BorderRadius.circular(8.r),
                  items: authController.hostels.map((hostel) {
                    return DropdownMenuItem<String>(
                      value: hostel,
                      child: Text(
                        hostel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      authController.setSelectedHostel(value);
                    }
                  },
                ),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 900.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 900.ms, duration: 400.ms),

        SizedBox(height: 40.h),

        // Register button
        ElevatedButton(
          onPressed: () => _register(),
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
            'Register',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 950.ms, duration: 400.ms)
            .moveY(begin: 20, end: 0, delay: 950.ms, duration: 400.ms),

        SizedBox(height: 24.h),

        // Back to login
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 400.ms)
                  .moveY(begin: 20, end: 0, delay: 1000.ms, duration: 400.ms),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1050.ms, duration: 400.ms)
                    .moveY(begin: 20, end: 0, delay: 1050.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
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
          suffixIcon: isPassword && toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20.r,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          errorStyle: TextStyle(
            fontSize: 12.sp,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
