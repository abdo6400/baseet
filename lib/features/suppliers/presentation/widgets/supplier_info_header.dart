import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierInfoHeader extends StatelessWidget {
  final SupplierEntity supplier;
  final bool showDebtBadge;

  const SupplierInfoHeader({
    super.key,
    required this.supplier,
    this.showDebtBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              supplier.name.isNotEmpty ? supplier.name[0] : 'م',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${supplier.companyName} • ${supplier.phone}',
                  style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                ),
                if (supplier.address != null && supplier.address!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supplier.address!,
                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (showDebtBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppPrimitiveTokens.amber500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${StringsManager.suppliersOwed.lang}: ${supplier.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppPrimitiveTokens.amber500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
