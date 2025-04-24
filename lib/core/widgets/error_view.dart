import 'package:flutter/material.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback? onRetry;
  final bool showIcon;
  final IconData? icon;
  final double? height;
  final double? width;

  const ErrorView({
    Key? key,
    this.message = 'Something went wrong',
    this.buttonText = 'Retry',
    this.onRetry,
    this.showIcon = true,
    this.icon,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height,
      width: width ?? MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 80.sp,
            ),
            SizedBox(height: 24.h),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
