import 'package:flutter/material.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class SupplierInvoiceItemRow extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final bool showDeleteButton;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onChanged;

  const SupplierInvoiceItemRow({
    super.key,
    required this.index,
    required this.nameController,
    required this.qtyController,
    required this.priceController,
    this.showDeleteButton = true,
    this.onDelete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = int.tryParse(qtyController.text) ?? 1;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final subtotal = qty * price;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppTextField(
                  controller: nameController,
                  label: StringsManager.suppliersItemName.lang,
                  hint: StringsManager.suppliersItemNameHint.lang,
                  onChanged: onChanged,
                ),
              ),
              if (showDeleteButton)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppPrimitiveTokens.red700, size: 20),
                  onPressed: onDelete,
                  tooltip: StringsManager.commonDelete.lang,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: qtyController,
                  label: StringsManager.suppliersItemQuantity.lang,
                  hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: AppTextField(
                  controller: priceController,
                  label: StringsManager.suppliersItemBuyPrice.lang,
                  hint: '0.0',
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      StringsManager.suppliersItemSubtotal.lang,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                    ),
                    Text(
                      '${subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
