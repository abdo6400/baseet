import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class ReceiptFinancialSummary extends StatelessWidget {
  final double totalPrice;
  final double paidAmount;
  final double changeAmount;

  const ReceiptFinancialSummary({
    super.key,
    required this.totalPrice,
    required this.paidAmount,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildRow(
          StringsManager.posTotal.lang,
          '${totalPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
          theme,
          isBold: true,
        ),
        _buildRow(
          StringsManager.receiptPaid.lang,
          '${paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
          theme,
        ),
        _buildRow(
          StringsManager.receiptChange.lang,
          '${changeAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
          theme,
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? theme.colorScheme.onSurface : theme.colorScheme.outline,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
