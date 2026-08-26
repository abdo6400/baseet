import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../pos/domain/entities/product_entity.dart';

class InventoryProductTile extends StatelessWidget {
  final ProductEntity product;

  const InventoryProductTile({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => AppIcon(AppIcons.inventory,
                        color: theme.colorScheme.onSurfaceVariant),
                  )
                : AppIcon(AppIcons.inventory,
                    color: theme.colorScheme.onSurfaceVariant),
          ),
          12.hSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                2.vSpace,
                Row(
                  children: [
                    Text(
                      product.categoryName,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    8.hSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? AppPrimitiveTokens.red700.withValues(alpha: 0.1)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${StringsManager.inventoryStockQuantityLabel.lang}: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: product.isLowStock
                              ? AppPrimitiveTokens.red700
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.sellPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${StringsManager.inventoryBuyPriceLabel.lang}: ${product.buyPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                style: TextStyle(
                    fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
