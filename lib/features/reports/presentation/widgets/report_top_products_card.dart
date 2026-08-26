import 'package:flutter/material.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/report_summary_entity.dart';

class ReportTopProductsCard extends StatelessWidget {
  final List<TopProductStat> products;

  const ReportTopProductsCard({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.reportsTopProducts.lang,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        12.vSpace,
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final prod = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppPrimitiveTokens.amber500.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: index == 0
                              ? AppPrimitiveTokens.amber700
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    12.hSpace,
                    Expanded(
                      child: Text(
                        prod.productName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${prod.totalRevenue.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${StringsManager.reportsSoldUnit.lang}: ${prod.soldQuantity}',
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
            },
          ),
        ),
      ],
    );
  }
}
