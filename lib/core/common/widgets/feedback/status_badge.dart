import 'package:flutter/material.dart';
import '../../../theme/tokens/app_tokens.dart';

enum StatusBadgeVariant { success, warning, error, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case StatusBadgeVariant.success:
        bg = AppPrimitiveTokens.emerald100;
        fg = AppPrimitiveTokens.emerald800;
        break;
      case StatusBadgeVariant.warning:
        bg = AppPrimitiveTokens.amber100;
        fg = AppPrimitiveTokens.amber800;
        break;
      case StatusBadgeVariant.error:
        bg = AppPrimitiveTokens.red100;
        fg = AppPrimitiveTokens.red800;
        break;
      case StatusBadgeVariant.neutral:
        bg = AppPrimitiveTokens.slate100;
        fg = AppPrimitiveTokens.slate700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
