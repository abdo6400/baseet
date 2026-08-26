import 'package:flutter/material.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/strings_manager.dart';

class SupplierInvoiceSummaryCard extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final ValueChanged<String?>? onPaidChanged;

  const SupplierInvoiceSummaryCard({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    this.onPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingAmount = (totalAmount - paidAmount) > 0 ? (totalAmount - paidAmount) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringsManager.suppliersPaymentDetails.lang,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          12.vSpace,
          AppFormTextField(
            name: 'paid_amount',
            label: StringsManager.suppliersPaidAmount.lang,
            hint: '0.0',
            keyboardType: TextInputType.number,
            validator: AppFormValidators.numeric(),
            onChanged: onPaidChanged,
          ),
          12.vSpace,
          AppFormTextField(
            name: 'notes',
            label: StringsManager.suppliersInvoiceNotes.lang,
            hint: StringsManager.suppliersInvoiceNotesHint.lang,
          ),
          const Divider(height: AppSpacing.lg),

          _buildRow(
            StringsManager.suppliersPurchasedGoods.lang,
            '${totalAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
            theme,
            isBold: true,
          ),
          _buildRow(
            StringsManager.checkoutCash.lang,
            '${paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
            theme,
          ),
          _buildRow(
            StringsManager.suppliersRemainingDebt.lang,
            '${remainingAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
            theme,
            isAlert: remainingAmount > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme, {bool isBold = false, bool isAlert = false}) {
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
              color: isAlert
                  ? AppPrimitiveTokens.amber500
                  : (isBold ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
