import 'package:flutter/material.dart';
import 'package:baseet/core/extensions/translation_extension.dart';

class DebtSummaryCarousel extends StatelessWidget {
  final double totalDebt, overdueDebt, todayCollections;
  const DebtSummaryCarousel(
      {super.key,
      required this.totalDebt,
      required this.overdueDebt,
      required this.todayCollections});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(spacing: 36, runSpacing: 12, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('simple.customer_debt'.lang),
                  Text('${totalDebt.toStringAsFixed(2)} ${'pos_currency'.lang}',
                      style: Theme.of(context).textTheme.headlineSmall)
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('simple.collected_today'.lang),
                  Text(
                      '${todayCollections.toStringAsFixed(2)} ${'pos_currency'.lang}',
                      style: Theme.of(context).textTheme.headlineSmall)
                ]),
              ]))));
}
