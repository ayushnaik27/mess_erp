import 'dart:math';
import 'package:get/get.dart';

class ScreenUtil {
  static double get width => Get.width;
  static double get height => Get.height;
  static double get statusBarHeight => Get.statusBarHeight;
  static double get bottomBarHeight => Get.bottomBarHeight;
  static double get textScaleFactor => Get.textScaleFactor;
  static double get pixelRatio => Get.pixelRatio;

  // Design size based on iPhone 12 Pro
  static const double designWidth = 390;
  static const double designHeight = 844;

  static double get scaleWidth => width / designWidth;
  static double get scaleHeight => height / designHeight;
  static double get scaleText => min(scaleWidth, scaleHeight);

  static double setWidth(double width) => width * scaleWidth;
  static double setHeight(double height) => height * scaleHeight;
  static double setSp(double fontSize) => fontSize * scaleText;
  static double radius(double r) => r * scaleText;
}
