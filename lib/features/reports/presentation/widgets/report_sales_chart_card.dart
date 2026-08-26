import 'package:flutter/material.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class ReportSalesChartCard extends StatelessWidget {
  final int totalInvoicesCount;

  const ReportSalesChartCard({
    super.key,
    required this.totalInvoicesCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.reportsSalesOverview.lang,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        12.vSpace,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringsManager.reportsInvoicesCount.lang,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$totalInvoicesCount ${StringsManager.reportsInvoiceUnit.lang}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              16.vSpace,

              // Weekly Bar Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ChartBar(label: StringsManager.daySat.lang, heightPercent: 0.6),
                  _ChartBar(label: StringsManager.daySun.lang, heightPercent: 0.8),
                  _ChartBar(label: StringsManager.dayMon.lang, heightPercent: 0.45),
                  _ChartBar(label: StringsManager.dayTue.lang, heightPercent: 0.9),
                  _ChartBar(label: StringsManager.dayWed.lang, heightPercent: 0.7),
                  _ChartBar(label: StringsManager.dayThu.lang, heightPercent: 1.0, isHighest: true),
                  _ChartBar(label: StringsManager.dayFri.lang, heightPercent: 0.5),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final double heightPercent;
  final bool isHighest;

  const _ChartBar({
    required this.label,
    required this.heightPercent,
    this.isHighest = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 90 * heightPercent,
          decoration: BoxDecoration(
            color: isHighest ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
        6.vSpace,
        Text(
          label,
          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
