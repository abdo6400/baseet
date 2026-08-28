import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/config/routes/app_routes.dart';
import 'package:baseet/core/common/widgets/feedback/empty_state_widget.dart';
import 'package:baseet/core/common/widgets/form/app_search_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/extensions/responsive_extension.dart';
import 'package:baseet/core/extensions/responsive_text_extension.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_state.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_category_filter_row.dart';
import '../widgets/inventory_product_tile.dart';
import '../widgets/inventory_stats_row.dart';

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
          style: context.label(
            22,
            weight: FontWeight.w800,
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
        icon: const AppIcon(AppIcons.add, color: Colors.white),
        label: Text(
          StringsManager.inventoryAddProduct.lang,
          style: context.label(14, weight: FontWeight.w700, color: Colors.white),
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
                    padding: EdgeInsets.all(context.safeDp(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.inventoryTitle.lang,
                          style: context.label(20, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          StringsManager.inventorySubtitle.lang,
                          style: context.label(
                            13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats Summary Row
                        InventoryStatsRow(state: state),
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
                            child: InventoryProductTile(product: product),
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
