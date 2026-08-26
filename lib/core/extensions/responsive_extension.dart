import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;

  double safeDp(double size) {
    if (isTablet) return size * 1.15;
    return size;
  }

  double sp(double size) {
    return safeDp(size);
  }
}
