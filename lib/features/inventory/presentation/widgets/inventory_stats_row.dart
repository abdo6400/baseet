import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/inventory_list/inventory_list_bloc.dart';
import '../blocs/inventory_list/inventory_list_event.dart';
import '../blocs/inventory_list/inventory_list_state.dart';

class InventoryStatsRow extends StatelessWidget {
  final InventoryListState state;

  const InventoryStatsRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringsManager.inventoryTotalProducts.lang,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
                4.vSpace,
                Text(
                  '${state.products.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        12.hSpace,
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<InventoryListBloc>().add(ToggleLowStockFilterEvent());
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: state.onlyLowStock
                    ? AppPrimitiveTokens.red700.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: state.onlyLowStock
                      ? AppPrimitiveTokens.red700
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringsManager.inventoryLowStock.lang,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (state.onlyLowStock)
                        AppIcon(AppIcons.check, size: 14, color: AppPrimitiveTokens.red700),
                    ],
                  ),
                  4.vSpace,
                  Text(
                    '${state.lowStockCount}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppPrimitiveTokens.red700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
