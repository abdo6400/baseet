import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import '../../domain/entities/business_data.dart';
import '../cubits/business_cubit.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});
  String receipt(SaleRecord sale) => [
        '${'simple.invoice'.lang} ${sale.number}',
        sale.date.toLocal().toString(),
        if (sale.customer != null) sale.customer!,
        ...sale.lines.map((line) =>
            '${line.name} × ${line.quantity} = ${(line.price * line.quantity).toStringAsFixed(2)}'),
        '${'simple.total'.lang}: ${sale.total.toStringAsFixed(2)}',
        '${'simple.paid'.lang}: ${sale.paid.toStringAsFixed(2)}',
        '${'simple.remaining'.lang}: ${sale.remaining.toStringAsFixed(2)}',
      ].join('\n');
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('simple.invoices'.lang)),
      body: BlocBuilder<BusinessCubit, BusinessState>(
          builder: (context, state) =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('simple.invoices_hint'.lang)),
                if (state.loading) const LinearProgressIndicator(),
                if (state.error != null) Text(state.error!.lang),
                Expanded(
                    child: state.data.sales.isEmpty
                        ? Center(child: Text('simple.no_invoices'.lang))
                        : ListView.separated(
                            itemCount: state.data.sales.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final sale = state.data.sales[index];
                              return ListTile(
                                  leading:
                                      const Icon(Icons.receipt_long_outlined),
                                  title: Text(sale.customer ??
                                      'simple.cash_customer'.lang),
                                  subtitle: Text(
                                      '${sale.date.toLocal().toString().substring(0, 16)} · ${sale.lines.length} ${'simple.items'.lang}'),
                                  trailing: Text(
                                      '${sale.total.toStringAsFixed(2)} ${'pos_currency'.lang}'),
                                  onTap: () => showDialog<void>(
                                      context: context,
                                      builder: (dialog) => AlertDialog(
                                              title:
                                                  Text('simple.invoice'.lang),
                                              content: SingleChildScrollView(
                                                  child: SelectableText(
                                                      receipt(sale))),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: receipt(
                                                                  sale)));
                                                      Navigator.pop(dialog);
                                                    },
                                                    child: Text(
                                                        'simple.copy_invoice'
                                                            .lang)),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(dialog),
                                                    child: Text(
                                                        'simple.close'.lang))
                                              ])));
                            })),
              ])));
}
