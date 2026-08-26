import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_invoice_entity.dart';

class SupplierInvoiceCard extends StatelessWidget {
  final SupplierInvoiceEntity invoice;
  final VoidCallback? onTap;

  const SupplierInvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outlineVariant),
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
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.receipt_long, size: 16, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Text(
                      '${StringsManager.suppliersInvoiceNo.lang} #${invoice.id}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                  style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),

            // Purchased items summary container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s2 + 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: invoice.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.productName} (x${item.quantity})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),

            // Totals Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${StringsManager.posTotal.lang}: ${invoice.totalAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  '${StringsManager.receiptPaid.lang}: ${invoice.paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                  style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                ),
                Text(
                  '${StringsManager.receiptChange.lang}: ${invoice.remainingAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                  style: const TextStyle(
                    color: AppPrimitiveTokens.amber500,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
