import 'package:flutter/widgets.dart';

extension SizeExtension on BuildContext {
  double wp(double percent) => MediaQuery.of(this).size.width * percent / 100;
  double hp(double percent) => MediaQuery.of(this).size.height * percent / 100;

  double tp(double percent) {
    final size = MediaQuery.of(this).size;
    final base = size.width < size.height ? size.width : size.height;
    return base * percent / 100;
  }
}
