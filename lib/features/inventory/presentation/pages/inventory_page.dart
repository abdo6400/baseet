import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/config/routes/app_routes.dart';
import 'package:baseet/core/common/widgets/feedback/empty_state_widget.dart';
import 'package:baseet/core/common/widgets/form/app_search_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_state.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_category_filter_row.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          StringsManager.appName.lang,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.tag, color: theme.colorScheme.primary),
            tooltip: StringsManager.inventoryAddCategory.lang,
            onPressed: () => context.push(AppRoutes.addCategory),
          ),
          IconButton(
            icon: AppIcon(AppIcons.box, color: theme.colorScheme.primary),
            tooltip: StringsManager.inventoryAddProduct.lang,
            onPressed: () => context.push(AppRoutes.addProduct),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_inventory_add_product',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.addProduct),
        icon: AppIcon(AppIcons.add, color: Colors.white),
        label: Text(
          StringsManager.inventoryAddProduct.lang,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<InventoryListBloc, InventoryListState>(
        builder: (context, state) {
          if (state.status == InventoryListStatus.loading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<InventoryListBloc>().add(const LoadInventoryEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          StringsManager.inventoryTitle.lang,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          StringsManager.inventorySubtitle.lang,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats Summary Row
                        Row(
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                            const SizedBox(width: 12),
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
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          if (state.onlyLowStock)
                                            AppIcon(AppIcons.check, size: 14, color: AppPrimitiveTokens.red700),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
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
                        ),
                        const SizedBox(height: 14),

                        // Search
                        AppSearchField(
                          controller: _searchController,
                          hint: StringsManager.inventorySearch.lang,
                          onChanged: (q) {
                            context.read<InventoryListBloc>().add(SearchInventoryEvent(q));
                          },
                        ),
                        const SizedBox(height: 14),

                        // Categories Row
                        if (state.categories.isNotEmpty)
                          PosCategoryFilterRow(
                            categories: state.categories,
                            selectedCategoryId: state.selectedCategoryId,
                            onSelect: (catId) {
                              context.read<InventoryListBloc>().add(SelectInventoryCategoryEvent(catId));
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Products List
                if (state.products.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: EmptyStateWidget(
                        title: StringsManager.commonEmpty.lang,
                        subtitle: StringsManager.inventoryNoProductsFound.lang,
                        icon: AppIcons.inventory,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = state.products[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
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
                                            errorBuilder: (_, __, ___) => AppIcon(AppIcons.inventory, color: theme.colorScheme.onSurfaceVariant),
                                          )
                                        : AppIcon(AppIcons.inventory, color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              product.categoryName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: state.products.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
