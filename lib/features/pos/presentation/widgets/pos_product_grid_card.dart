import 'package:flutter/material.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';

class PosProductGridCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onAddToCart;
  const PosProductGridCard(
      {super.key, required this.product, required this.onAddToCart});
  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
                '${product.sellPrice.toStringAsFixed(2)} ${'pos_currency'.lang}',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('${'simple.quantity'.lang}: ${product.stockQuantity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: product.stockQuantity <= 0 ? null : onAddToCart,
                child: Text((product.stockQuantity <= 0
                        ? 'simple.sold_out'
                        : 'simple.add')
                    .lang)),
          ])));
}
