import 'package:mess_erp/core/utils/screen_utils.dart';

extension SizeExtension on num {
  double get w => ScreenUtil.setWidth(toDouble());
  double get h => ScreenUtil.setHeight(toDouble());
  double get sp => ScreenUtil.setSp(toDouble());
  double get r => ScreenUtil.radius(toDouble());
}
