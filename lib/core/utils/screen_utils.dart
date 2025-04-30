import 'package:flutter/material.dart';
import 'dart:math';

class ScreenUtil {
  static ScreenUtil instance = ScreenUtil();

  static const double designWidth = 390;
  static const double designHeight = 844;

  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _statusBarHeight = 0;
  static double _bottomBarHeight = 0;
  static double _textScaleFactor = 1.0;

  static bool _initialized = false;

  void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = mediaQuery.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _initialized = true;
  }

  static double get width {
    _checkInit();
    return _screenWidth;
  }

  static double get height {
    _checkInit();
    return _screenHeight;
  }

  static double get statusBarHeight {
    _checkInit();
    return _statusBarHeight;
  }

  static double get bottomBarHeight {
    _checkInit();
    return _bottomBarHeight;
  }

  static double get textScaleFactor {
    _checkInit();
    return _textScaleFactor;
  }

  static double get scaleWidth => width / designWidth;
  static double get scaleHeight => height / designHeight;
  static double get scaleText => min(scaleWidth, scaleHeight);

  static double setWidth(double width) => width * scaleWidth;
  static double setHeight(double height) => height * scaleHeight;
  static double setSp(double fontSize) => fontSize * scaleText;
  static double radius(double r) => r * scaleText;

  static void _checkInit() {
    if (!_initialized) {
      _screenWidth = 390;
      _screenHeight = 844;
    }
  }
}
