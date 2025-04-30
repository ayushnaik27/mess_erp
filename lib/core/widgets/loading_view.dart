import 'package:flutter/material.dart';
import 'package:mess_erp/core/extensions/size_extension.dart';
import 'package:mess_erp/core/theme/app_colors.dart';

class LoadingView extends StatelessWidget {
  final String message;
  final bool showProgressIndicator;
  final double? height;
  final double? width;

  const LoadingView({
    Key? key,
    this.message = 'Loading...',
    this.showProgressIndicator = true,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height,
      width: width ?? MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgressIndicator) ...[
            SizedBox(
              width: 50.w,
              height: 50.h,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3.w,
              ),
            ),
            SizedBox(height: 24.h),
          ],
          if (message.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
