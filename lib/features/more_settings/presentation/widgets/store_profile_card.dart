import 'package:flutter/material.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class StoreProfileCard extends StatelessWidget {
  const StoreProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const AppLogo(size: 52, showText: false),
          14.hSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringsManager.moreDefaultStoreName.lang,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                4.vSpace,
                Text(
                  StringsManager.moreDefaultCashierName.lang,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
