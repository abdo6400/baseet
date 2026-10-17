import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/features/reports/domain/entities/report_period.dart';
import '../blocs/reports/reports_bloc.dart';
import '../blocs/reports/reports_event.dart';
import '../blocs/reports/reports_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const LoadReportsSummaryEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('simple.reports'.lang)),
      body: BlocBuilder<ReportsBloc, ReportsState>(builder: (context, state) {
        final summary = state.summary;
        return ListView(padding: const EdgeInsets.all(20), children: [
          Wrap(
              spacing: 8,
              children: ReportPeriod.values
                  .map((period) => ChoiceChip(
                      label: Text('simple.period_${period.name}'.lang),
                      selected: period == state.period,
                      onSelected: (_) => context
                          .read<ReportsBloc>()
                          .add(LoadReportsSummaryEvent(period: period))))
                  .toList()),
          const SizedBox(height: 16),
          if (state.status == ReportsStatus.loading)
            const LinearProgressIndicator(),
          if (state.errorMessage != null) Text(state.errorMessage!.lang),
          if (summary != null) ...[
            _Total('simple.total_sales', summary.totalSales),
            _Total('simple.cash_sales', summary.cashSales),
            _Total('simple.credit_sales', summary.debtSales),
            _Total('simple.estimated_profit', summary.netProfit),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('simple.profit_hint'.lang)),
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('simple.invoice_count'.lang),
                trailing: Text('${summary.totalInvoicesCount}')),
            const Divider(height: 32),
            Text('simple.top_products'.lang,
                style: Theme.of(context).textTheme.titleLarge),
            if (summary.topProducts.isEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('simple.no_invoices'.lang)),
            ...summary.topProducts.map((product) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(product.productName),
                subtitle:
                    Text('${product.soldQuantity} ${'simple.sold_units'.lang}'),
                trailing: Text(
                    '${product.totalRevenue.toStringAsFixed(2)} ${'pos_currency'.lang}'))),
          ],
        ]);
      }));
}

class _Total extends StatelessWidget {
  final String label;
  final double value;
  const _Total(this.label, this.value);
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(label.lang,
                    style: Theme.of(context).textTheme.titleMedium),
                Text('${value.toStringAsFixed(2)} ${'pos_currency'.lang}',
                    style: Theme.of(context).textTheme.titleLarge)
              ])));
}
