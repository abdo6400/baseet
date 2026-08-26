import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_search_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/scanner/barcode_scanner_modal.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/catalog/pos_catalog_bloc.dart';
import '../blocs/catalog/pos_catalog_event.dart';
import '../blocs/catalog/pos_catalog_state.dart';
import '../widgets/pos_category_filter_row.dart';
import '../widgets/pos_floating_cart_bar.dart';
import '../widgets/pos_header_sales_card.dart';
import '../widgets/pos_product_grid_card.dart';

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
      final product = catalogState.products.where((p) => p.barcode == scannedBarcode).firstOrNull;
      if (product != null) {
        context.read<CartBloc>().add(AddProductToCartEvent(product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsManager.barcodeProductAdded.trArgs(args: [product.name])),
            backgroundColor: AppPrimitiveTokens.emerald700,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _searchController.text = scannedBarcode;
        context.read<PosCatalogBloc>().add(SearchCatalogEvent(scannedBarcode));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsManager.barcodeProductNotFound.trArgs(args: [scannedBarcode])),
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
          StringsManager.appName.lang,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              alignment: Alignment.center,
              child: Text(
                StringsManager.cashier.lang,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
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
              if (state.status == PosCatalogStatus.loading && state.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
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
                                context.read<PosCatalogBloc>().add(SearchCatalogEvent(q));
                              },
                            ),
                            const SizedBox(height: 14),

                            // Category Filters
                            if (state.categories.isNotEmpty)
                              PosCategoryFilterRow(
                                categories: state.categories,
                                selectedCategoryId: state.selectedCategoryId,
                                onSelect: (catId) {
                                  context.read<PosCatalogBloc>().add(SelectCategoryEvent(catId));
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = state.products[index];
                              return BlocBuilder<CartBloc, CartState>(
                                builder: (context, cartState) {
                                  final cartItem = cartState.items
                                      .where((i) => i.product.id == product.id)
                                      .firstOrNull;
                                  final qty = cartItem?.quantity ?? 0;
                                  return PosProductGridCard(
                                    product: product,
                                    cartQuantity: qty,
                                    onAddToCart: () {
                                      context.read<CartBloc>().add(AddProductToCartEvent(product));
                                    },
                                  );
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
