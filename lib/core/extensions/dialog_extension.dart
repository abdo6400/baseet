import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/widgets/icon/app_icon.dart';
import '../extensions/spacing_extension.dart';
import '../theme/tokens/app_tokens.dart';
import '../utils/app_icons.dart';
import '../utils/strings_manager.dart';
import 'translation_extension.dart';

extension DialogExtension on BuildContext {
  Future<bool?> showExitAppDialog() {
    final theme = Theme.of(this);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: this,
      barrierDismissible: true,
      builder: (context) => Dialog(
        elevation: 12,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header with Soft Glow
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppPrimitiveTokens.amber500.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppPrimitiveTokens.amber500.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AppIcon(
                    AppIcons.warning,
                    color: AppPrimitiveTokens.amber500,
                    size: 28,
                  ),
                ),
              ),
              16.vSpace,

              // Title
              Text(
                StringsManager.commonExitTitle.lang,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              8.vSpace,

              // Content Message
              Text(
                StringsManager.commonExitMessage.lang,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              22.vSpace,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        StringsManager.commonCancel.lang,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        StringsManager.commonConfirm.lang,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(this);
    final isDark = theme.brightness == Brightness.dark;
    final primaryActionColor = isDestructive ? AppPrimitiveTokens.red700 : theme.colorScheme.primary;

    return showDialog<bool>(
      context: this,
      barrierDismissible: true,
      builder: (context) => Dialog(
        elevation: 12,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header with Soft Glow
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryActionColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryActionColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AppIcon(
                    isDestructive ? AppIcons.delete : AppIcons.info,
                    color: primaryActionColor,
                    size: 28,
                  ),
                ),
              ),
              16.vSpace,

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              8.vSpace,

              // Content Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              22.vSpace,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        cancelText ?? StringsManager.commonCancel.lang,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryActionColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        confirmText ?? StringsManager.commonConfirm.lang,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
