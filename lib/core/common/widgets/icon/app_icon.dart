import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../utils/app_icons.dart';

class AppIcon extends StatelessWidget {
  final dynamic icon;
  final double? size;
  final Color? color;
  final bool? matchTextDirection;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.matchTextDirection,
  });

  bool _isDirectional(dynamic icon) {
    if (matchTextDirection != null) return matchTextDirection!;
    return icon == AppIcons.arrowBack ||
        icon == AppIcons.arrowForward ||
        icon == AppIcons.arrowBackIos ||
        icon == Icons.arrow_back ||
        icon == Icons.arrow_forward ||
        icon == Icons.chevron_left ||
        icon == Icons.chevron_right ||
        icon == Icons.arrow_back_ios ||
        icon == Icons.arrow_forward_ios ||
        icon == Icons.navigate_next ||
        icon == Icons.navigate_before;
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    final defaultSize = IconTheme.of(context).size ?? 24.0;

    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(
        icon as IconData,
        size: size ?? defaultSize,
        color: color ?? defaultColor,
      );
    } else {
      iconWidget = HugeIcon(
        icon: icon,
        color: color ?? defaultColor,
        size: size ?? defaultSize,
      );
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (_isDirectional(icon) && isRtl) {
      return Transform.flip(
        flipX: true,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
