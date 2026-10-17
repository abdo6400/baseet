import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/app/router/app_routes.dart';
import 'package:baseet/core/common/widgets/feedback/empty_state_widget.dart';
import 'package:baseet/core/common/widgets/form/app_search_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_event.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_state.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_event.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_state.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_category_filter_row.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_floating_cart_bar.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_header_sales_card.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_product_grid_card.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startBarcodeScanning() async {
    final scannedBarcode = await BarcodeScannerModal.show(context);
    if (scannedBarcode != null && scannedBarcode.isNotEmpty && mounted) {
      final catalogState = context.read<PosCatalogBloc>().state;
      final product = catalogState.products
          .where((p) => p.barcode == scannedBarcode)
          .firstOrNull;
      if (product != null) {
        context.read<CartBloc>().add(AddProductToCartEvent(product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsManager.barcodeProductAdded
                .trArgs(args: [product.name])),
            backgroundColor: AppPrimitiveTokens.emerald700,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _searchController.text = scannedBarcode;
        context.read<PosCatalogBloc>().add(SearchCatalogEvent(scannedBarcode));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsManager.barcodeProductNotFound
                .trArgs(args: [scannedBarcode])),
            backgroundColor: AppPrimitiveTokens.red700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
        leading: IconButton(
          icon: AppIcon(AppIcons.barcode, color: theme.colorScheme.primary),
          onPressed: _startBarcodeScanning,
        ),
        title: Text(
          StringsManager.posTitle.lang,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<PosCatalogBloc, PosCatalogState>(
            builder: (context, state) {
              if (state.status == PosCatalogStatus.loading &&
                  state.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<PosCatalogBloc>()
                      .add(const LoadPosCatalogEvent());
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Daily Sales Card
                            PosHeaderSalesCard(todaySales: state.todaySales),
                            const SizedBox(height: 14),

                            // Search Field
                            AppSearchField(
                              controller: _searchController,
                              hint: StringsManager.posSearchProduct.lang,
                              onBarcodeTap: _startBarcodeScanning,
                              onChanged: (q) {
                                context
                                    .read<PosCatalogBloc>()
                                    .add(SearchCatalogEvent(q));
                              },
                            ),
                            const SizedBox(height: 14),

                            // Category Filters
                            if (state.categories.isNotEmpty)
                              PosCategoryFilterRow(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onSelect: (catId) {
                                  context
                                      .read<PosCatalogBloc>()
                                      .add(SelectCategoryEvent(catId));
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Products Grid
                    if (state.products.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: EmptyStateWidget(
                            title: StringsManager.commonEmpty.lang,
                            subtitle: StringsManager.posNoProductsFound.lang,
                            icon: AppIcons.inventory,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            mainAxisExtent: 190,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = state.products[index];
                              return PosProductGridCard(
                                product: product,
                                onAddToCart: () {
                                  final quantity = context
                                      .read<CartBloc>()
                                      .state
                                      .items
                                      .where((item) =>
                                          item.product.id == product.id)
                                      .fold<int>(0,
                                          (sum, item) => sum + item.quantity);
                                  if (quantity >= product.stockQuantity) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'simple.stock_limit'.lang)));
                                    return;
                                  }
                                  context
                                      .read<CartBloc>()
                                      .add(AddProductToCartEvent(product));
                                },
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

          // Floating Cart Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return PosFloatingCartBar(
                  itemCount: cartState.totalItemCount,
                  totalPrice: cartState.totalPrice,
                  onCheckout: () {
                    context.push(AppRoutes.checkout);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
