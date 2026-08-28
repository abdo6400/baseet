import 'package:flutter/material.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationKeyInputCard extends StatelessWidget {
  final TextEditingController keyController;
  final FocusNode keyFocusNode;
  final bool isActivating;
  final bool isExpiredState;
  final bool seedDummyData;
  final ValueChanged<bool> onSeedDummyDataChanged;
  final VoidCallback onPaste;
  final VoidCallback onActivate;

  const ActivationKeyInputCard({
    super.key,
    required this.keyController,
    required this.keyFocusNode,
    required this.isActivating,
    required this.isExpiredState,
    required this.seedDummyData,
    required this.onSeedDummyDataChanged,
    required this.onPaste,
    required this.onActivate,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      AppIcons.key,
                      color: theme.colorScheme.primary,
                      size: context.safeDp(18),
                    ),
                  ),
                  10.hSpace,
                  Text(
                    StringsManager.activationKeyLabel.lang,
                    style: context.label(
                      14,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onPaste,
                icon: AppIcon(AppIcons.copy, size: context.safeDp(16)),
                label: Text(
                  StringsManager.activationPaste.lang,
                  style: context.label(
                    12,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          10.vSpace,
          TextField(
            controller: keyController,
            focusNode: keyFocusNode,
            maxLines: 2,
            style: context.label(
              13,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: StringsManager.activationKeyHint.lang,
              hintStyle: context.label(
                12,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surfaceContainer
                  : AppPrimitiveTokens.slate50,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
          ),

          // Dummy Data Seed Option (initial setup only)
          if (!isExpiredState) ...[
            14.vSpace,
            InkWell(
              onTap: () => onSeedDummyDataChanged(!seedDummyData),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.safeDp(10),
                  vertical: context.safeDp(8),
                ),
                decoration: BoxDecoration(
                  color: seedDummyData
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : (isDark
                          ? theme.colorScheme.surfaceContainer
                          : AppPrimitiveTokens.slate50),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: seedDummyData
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: seedDummyData ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: seedDummyData,
                      onChanged: (val) => onSeedDummyDataChanged(val ?? false),
                      activeColor: theme.colorScheme.primary,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    6.hSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringsManager.activationSeedDummyData.lang,
                            style: context.label(
                              13,
                              weight: FontWeight.w700,
                              color: seedDummyData
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          2.vSpace,
                          Text(
                            StringsManager.activationSeedDummyDataDesc.lang,
                            style: context.label(
                              11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          16.vSpace,
          AppButton(
            text: isExpiredState
                ? StringsManager.activationRenewBtn.lang
                : StringsManager.activationBtn.lang,
            icon: AppIcons.check,
            isLoading: isActivating,
            onPressed: onActivate,
          ),
        ],
      ),
    );
  }
}
