import 'package:flutter/material.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AboutAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      elevation: 16,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.safeDp(24),
        vertical: context.safeDp(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.isTablet ? 480 : 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with soft ambient container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const AppLogo(size: 72, showText: false),
              ),
              16.vSpace,

              // App Name
              Text(
                StringsManager.appName.lang,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              6.vSpace,

              // Version Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'v1.0.0 (Build 1)',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              12.vSpace,

              // Subtitle
              Text(
                StringsManager.appSubtitle.lang,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              10.vSpace,

              // Description
              Text(
                StringsManager.aboutAppDescription.lang,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              22.vSpace,

              // Close Button
              AppButton(
                text: StringsManager.commonCancel.lang,
                height: 42,
                borderRadius: AppRadius.full,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
