import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/assets_manager.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool useImageAsset;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.useImageAsset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark
        ? AppPrimitiveTokens.emerald400
        : theme.colorScheme.primary;

    final textColor = isDark
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.26),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.26),
            child: useImageAsset
                ? Image.asset(
                    AssetsManager.getAppIcon(isDark: isDark),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppPrimitiveTokens.emerald700, AppPrimitiveTokens.emerald500]
                            : [theme.colorScheme.primary, AppPrimitiveTokens.slate800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: size * 0.58,
                      ),
                    ),
                  ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بسيط',
                style: TextStyle(
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              Text(
                'BASEET POS',
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: primaryColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
