import 'package:flutter/material.dart';

extension SpacingExtension on num {
  Widget get vSpace => SizedBox(height: toDouble());
  Widget get hSpace => SizedBox(width: toDouble());

  double r(BuildContext context) {
    // responsive scaling helper
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return toDouble() * 1.2;
    }
    return toDouble();
  }
}
