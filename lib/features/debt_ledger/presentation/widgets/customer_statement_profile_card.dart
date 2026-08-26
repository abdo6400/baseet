import 'package:flutter/material.dart';
import '../../../../core/common/widgets/feedback/status_badge.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerStatementProfileCard extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerStatementProfileCard({
    super.key,
    required this.customer,
  });

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  2.vSpace,
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: customer.isOverdue
                    ? StringsManager.debtsStatusOverdue.lang
                    : StringsManager.debtsStatusRegular.lang,
                variant: customer.isOverdue
                    ? StatusBadgeVariant.error
                    : StatusBadgeVariant.success,
              ),
            ],
          ),
          16.vSpace,
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
          16.vSpace,

          // Balance & Limit Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringsManager.customerTotalBalance.lang,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  4.vSpace,
                  Text(
                    '${customer.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: customer.totalDebt > 0
                          ? AppPrimitiveTokens.red700
                          : AppPrimitiveTokens.emerald700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StringsManager.customerCreditLimit.lang,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  4.vSpace,
                  Text(
                    '${customer.creditLimit.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          12.vSpace,

          // Credit Limit Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: customer.limitUsagePercent,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                customer.isLimitExceeded
                    ? AppPrimitiveTokens.red700
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
