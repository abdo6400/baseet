import 'package:flutter/material.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationDeviceIdCard extends StatelessWidget {
  final String deviceId;
  final bool isLoadingDevice;
  final VoidCallback onCopy;
  final VoidCallback onSendWhatsApp;

  const ActivationDeviceIdCard({
    super.key,
    required this.deviceId,
    required this.isLoadingDevice,
    required this.onCopy,
    required this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(context.safeDp(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.safeDp(8)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  AppIcons.shield,
                  color: theme.colorScheme.primary,
                  size: context.safeDp(18),
                ),
              ),
              10.hSpace,
              Expanded(
                child: Text(
                  StringsManager.activationDeviceId.lang,
                  style: context.label(
                    14,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          12.vSpace,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.safeDp(14),
              vertical: context.safeDp(12),
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer
                  : AppPrimitiveTokens.slate100,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLoadingDevice
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : SelectableText(
                          deviceId,
                          style: context.label(
                            16,
                            weight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
                8.hSpace,
                IconButton(
                  tooltip: StringsManager.activationCopyDeviceId.lang,
                  icon: AppIcon(
                    AppIcons.copy,
                    size: context.safeDp(20),
                  ),
                  onPressed: onCopy,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          12.vSpace,
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  text: StringsManager.activationCopyDeviceId.lang,
                  icon: AppIcons.copy,
                  height: context.safeDp(40),
                  onPressed: onCopy,
                ),
              ),
              10.hSpace,
              Expanded(
                child: AppOutlinedButton(
                  text: StringsManager.activationSendToWhatsApp.lang,
                  icon: AppIcons.whatsapp,
                  height: context.safeDp(40),
                  onPressed: onSendWhatsApp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
