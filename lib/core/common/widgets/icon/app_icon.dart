import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppIcon extends StatelessWidget {
  final dynamic icon;
  final double? size;
  final Color? color;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    final defaultSize = IconTheme.of(context).size ?? 24.0;

    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: size ?? defaultSize,
        color: color ?? defaultColor,
      );
    }

    return HugeIcon(
      icon: icon,
      color: color ?? defaultColor,
      size: size ?? defaultSize,
    );
  }
}
