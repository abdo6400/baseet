import 'package:flutter/material.dart';
import '../../../theme/tokens/app_tokens.dart';
import '../icon/app_icon.dart';

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final dynamic icon;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.width,
    this.height = 46.0,
    this.borderRadius = AppRadius.md,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = borderColor ?? theme.colorScheme.outlineVariant;
    final textCol = textColor ?? theme.colorScheme.onSurface;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              AppIcon(icon, size: 16, color: textCol),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
