import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/cart_item_entity.dart';

class ReceiptItemTile extends StatelessWidget {
  final int index;
  final CartItemEntity item;

  const ReceiptItemTile({
    super.key,
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
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
        const SizedBox(width: AppSpacing.s2 + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (item.product.barcode.isNotEmpty)
                Text(
                  '${StringsManager.addProductBarcode.lang}: ${item.product.barcode}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
            ],
          ),
        ),
        Text(
          'x${item.quantity} (${item.product.sellPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang})',
          style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}
