import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/app/router/app_routes.dart';
import '../cubits/business_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('simple.home'.lang), actions: [
          IconButton(
              tooltip: 'simple.refresh'.lang,
              onPressed: () => context.read<BusinessCubit>().load(),
              icon: const Icon(Icons.refresh)),
        ]),
        body: BlocBuilder<BusinessCubit, BusinessState>(
            builder: (context, state) {
          final data = state.data;
          final theme = Theme.of(context);
          return RefreshIndicator(
              onRefresh: () => context.read<BusinessCubit>().load(),
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text(data.storeName.isEmpty ? 'app_name'.lang : data.storeName,
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('simple.home_hint'.lang),
                const SizedBox(height: 16),
                if (state.loading) const LinearProgressIndicator(),
                if (state.error != null)
                  Text(state.error!.lang,
                      style: TextStyle(color: theme.colorScheme.error)),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _Stat('simple.today_sales', data.todaySales)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Stat('simple.customer_debt', data.totalDebt)),
                ]),
                if (data.lowStock > 0)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                          onPressed: () => context.go(AppRoutes.inventory),
                          icon: const Icon(Icons.warning_amber),
                          label: Text(
                              '${'simple.low_stock'.lang}: ${data.lowStock}'))),
                if (!state.loading && data.products.isEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: const Icon(Icons.add_circle_outline),
                            title: Text('simple.first_product'.lang),
                            subtitle: Text('simple.first_product_hint'.lang),
                            onTap: () => context.push(AppRoutes.addProduct),
                          ))),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, box) {
                  final wide = box.maxWidth > 800;
                  final columns = wide ? 3 : 2;
                  final items = [
                    (
                      'simple.sell',
                      'simple.sell_hint',
                      Icons.shopping_cart_outlined,
                      AppRoutes.pos
                    ),
                    (
                      'simple.products',
                      'simple.products_hint',
                      Icons.inventory_2_outlined,
                      AppRoutes.inventory
                    ),
                    (
                      'simple.customers',
                      'simple.customers_hint',
                      Icons.people_outline,
                      AppRoutes.debts
                    ),
                    (
                      'simple.invoices',
                      'simple.invoices_hint',
                      Icons.receipt_long_outlined,
                      AppRoutes.sales
                    ),
                    (
                      'simple.reports',
                      'simple.reports_hint',
                      Icons.bar_chart_outlined,
                      AppRoutes.reports
                    ),
                    (
                      'simple.transfer',
                      'simple.transfer_hint',
                      Icons.qr_code_2,
                      AppRoutes.transfer
                    ),
                  ];
                  return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: items
                          .map((item) => SizedBox(
                              width:
                                  (box.maxWidth - 10 * (columns - 1)) / columns,
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      if (item.$4 == AppRoutes.sales ||
                                          item.$4 == AppRoutes.transfer) {
                                        context.push(item.$4);
                                      } else {
                                        context.go(item.$4);
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(item.$3,
                                                  size: 28,
                                                  color: theme
                                                      .colorScheme.primary),
                                              const SizedBox(height: 10),
                                              Text(item.$1.lang,
                                                  style: theme
                                                      .textTheme.titleMedium),
                                              if (wide) ...[
                                                const SizedBox(height: 6),
                                                Text(item.$2.lang)
                                              ],
                                            ])),
                                  ))))
                          .toList());
                }),
                const SizedBox(height: 12),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.settings_outlined),
                    title: Text('simple.settings'.lang),
                    onTap: () => context.go(AppRoutes.more)),
                Text('simple.local_only'.lang,
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
              ]));
        }),
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.lang),
            const SizedBox(height: 4),
            Text('${value.toStringAsFixed(2)} ${'pos_currency'.lang}',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ])));
}
