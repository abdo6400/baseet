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

    return Container(
      padding: EdgeInsets.all(context.safeDp(14)),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.4)
            : AppPrimitiveTokens.slate100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppIcon(
              AppIcons.info,
              size: context.safeDp(16),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          8.hSpace,
          Expanded(
            child: Text(
              StringsManager.activationInstructions.lang,
              style: context.label(
                12,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
