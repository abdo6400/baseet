import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/scanner/receipt_preview_dialog.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/debt_transaction_entity.dart';

class CustomerTransactionTile extends StatelessWidget {
  final DebtTransactionEntity transaction;

  const CustomerTransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPayment = transaction.type == TransactionType.paymentVoucher;
    final accentColor = isPayment ? AppPrimitiveTokens.emerald700 : AppPrimitiveTokens.red700;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              isPayment ? AppIcons.payments : AppIcons.receipt,
              color: accentColor,
              size: 20,
            ),
          ),
          12.hSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPayment ? StringsManager.customerTypePayment.lang : StringsManager.customerTypeSale.lang,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (transaction.notes != null) ...[
                  2.vSpace,
                  Text(
                    transaction.notes!,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (transaction.itemsSummary != null && transaction.itemsSummary!.isNotEmpty) ...[
                  4.vSpace,
                  Text(
                    transaction.itemsSummary!.join(' • '),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                2.vSpace,
                Row(
                  children: [
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    if (transaction.receiptPath != null && transaction.receiptPath!.isNotEmpty) ...[
                      8.hSpace,
                      InkWell(
                        onTap: () => ReceiptPreviewDialog.show(
                          context,
                          imagePath: transaction.receiptPath!,
                          title: StringsManager.receiptView.lang,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(AppIcons.receipt, size: 10, color: theme.colorScheme.primary),
                              3.hSpace,
                              Text(
                                StringsManager.receiptView.lang,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPayment ? "-" : "+"}${transaction.amount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: accentColor,
                ),
              ),
              2.vSpace,
              Text(
                '${StringsManager.customerTotalBalance.lang}: ${transaction.remainingBalance.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
