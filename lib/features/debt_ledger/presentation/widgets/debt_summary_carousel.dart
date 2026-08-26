import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class DebtSummaryCarousel extends StatelessWidget {
  final double totalDebt;
  final double overdueDebt;
  final double todayCollections;

  const DebtSummaryCarousel({
    super.key,
    required this.totalDebt,
    required this.overdueDebt,
    required this.todayCollections,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSummaryCard(
            context,
            title: StringsManager.debtsTotal.lang,
            value: totalDebt.toStringAsFixed(0),
            color: AppPrimitiveTokens.red700,
            icon: AppIcons.wallet,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            title: StringsManager.debtsOverdue.lang,
            value: overdueDebt.toStringAsFixed(0),
            color: AppPrimitiveTokens.red800,
            icon: AppIcons.warning,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            context,
            title: StringsManager.debtsTodayCollections.lang,
            value: todayCollections.toStringAsFixed(0),
            color: AppPrimitiveTokens.emerald700,
            icon: AppIcons.payments,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required dynamic icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 190,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(color: color),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(icon, size: 16, color: color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      StringsManager.posCurrency.lang,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
