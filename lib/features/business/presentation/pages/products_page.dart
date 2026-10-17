import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/app/router/app_routes.dart';
import '../cubits/business_cubit.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String query = '';
  bool lowOnly = false;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('simple.products'.lang), actions: [
        IconButton(
            tooltip: 'simple.refresh'.lang,
            onPressed: () => context.read<BusinessCubit>().load(),
            icon: const Icon(Icons.refresh))
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.addProduct),
          icon: const Icon(Icons.add),
          label: Text('simple.add_product'.lang)),
      body:
          BlocBuilder<BusinessCubit, BusinessState>(builder: (context, state) {
        final products = state.data.products
            .where((p) =>
                (!lowOnly || p.isLowStock) &&
                (p.name.toLowerCase().contains(query.toLowerCase()) ||
                    p.barcode.contains(query)))
            .toList();
        return Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'simple.product_search'.lang),
                  onChanged: (value) => setState(() => query = value))),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                FilterChip(
                    label: Text('simple.low_stock'.lang),
                    selected: lowOnly,
                    onSelected: (value) => setState(() => lowOnly = value)),
                const Spacer(),
                Text('${products.length} ${'simple.products'.lang}')
              ])),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null) Text(state.error!.lang),
          Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('simple.no_products'.lang,
                              textAlign: TextAlign.center)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            leading: CircleAvatar(
                                child: Icon(product.isLowStock
                                    ? Icons.warning_amber
                                    : Icons.inventory_2_outlined)),
                            title: Text(product.name),
                            subtitle: Text(
                                '${'simple.quantity'.lang}: ${product.stockQuantity}'),
                            trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${product.sellPrice.toStringAsFixed(2)} ${'pos_currency'.lang}'),
                                  Text('simple.edit'.lang,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary))
                                ]),
                            onTap: () => context
                                .push(AppRoutes.editProductPath(product.id)));
                      })),
        ]);
      }));
}
