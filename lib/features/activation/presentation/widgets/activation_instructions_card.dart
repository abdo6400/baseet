import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationInstructionsCard extends StatelessWidget {
  const ActivationInstructionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      StringsManager.activationInstructionsStep1.lang,
      StringsManager.activationInstructionsStep2.lang,
      StringsManager.activationInstructionsStep3.lang,
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.safeDp(14),
        vertical: context.safeDp(12),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : AppPrimitiveTokens.slate100.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                AppIcons.info,
                size: context.safeDp(15),
                color: theme.colorScheme.primary,
              ),
              6.hSpace,
              Text(
                StringsManager.activationInstructionsTitle.lang,
                style: context.label(
                  12,
                  weight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          8.vSpace,
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0) 6.vSpace,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.safeDp(18),
                  height: context.safeDp(18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: context.label(
                      10,
                      weight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                8.hSpace,
                Expanded(
                  child: Text(
                    steps[i],
                    style: context.label(
                      11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
