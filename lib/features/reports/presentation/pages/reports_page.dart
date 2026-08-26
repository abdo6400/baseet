import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/reports/reports_bloc.dart';
import '../blocs/reports/reports_event.dart';
import '../blocs/reports/reports_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(LoadReportsSummaryEvent(period: _selectedPeriod));
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading && state.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = state.summary;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReportsBloc>().add(LoadReportsSummaryEvent(period: _selectedPeriod));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    StringsManager.reportsTitle.lang,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    StringsManager.reportsSubtitle.lang,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Period Tabs Row
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodTab('today', StringsManager.reportsPeriodToday.lang),
                        _buildPeriodTab('week', StringsManager.reportsPeriodWeek.lang),
                        _buildPeriodTab('month', StringsManager.reportsPeriodMonth.lang),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (summary != null) ...[
                    // Primary Stats (Profit & Total Sales)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            theme,
                            title: StringsManager.reportsNetProfit.lang,
                            value: '${summary.netProfit.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: AppPrimitiveTokens.emerald700,
                            icon: AppIcons.trendingUp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            theme,
                            title: StringsManager.reportsTotalSales.lang,
                            value: '${summary.totalSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: theme.colorScheme.primary,
                            icon: AppIcons.pos,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Secondary Stats (Cash vs Debt)
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            theme,
                            title: StringsManager.reportsCashCollected.lang,
                            value: '${summary.cashSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: AppPrimitiveTokens.emerald700,
                            icon: AppIcons.payments,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            theme,
                            title: StringsManager.reportsDebtSales.lang,
                            value: '${summary.debtSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: AppPrimitiveTokens.red700,
                            icon: AppIcons.debts,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sales Visual Overview
                    Text(
                      StringsManager.reportsSalesOverview.lang,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
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
                                '${summary.totalInvoicesCount} ${StringsManager.reportsInvoiceUnit.lang}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Simple bar chart representation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar(theme, label: StringsManager.daySat.lang, heightPercent: 0.6),
                              _buildBar(theme, label: StringsManager.daySun.lang, heightPercent: 0.8),
                              _buildBar(theme, label: StringsManager.dayMon.lang, heightPercent: 0.45),
                              _buildBar(theme, label: StringsManager.dayTue.lang, heightPercent: 0.9),
                              _buildBar(theme, label: StringsManager.dayWed.lang, heightPercent: 0.7),
                              _buildBar(theme, label: StringsManager.dayThu.lang, heightPercent: 1.0, isHighest: true),
                              _buildBar(theme, label: StringsManager.dayFri.lang, heightPercent: 0.5),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top Selling Products Leaderboard
                    Text(
                      StringsManager.reportsTopProducts.lang,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: summary.topProducts.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final prod = summary.topProducts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? AppPrimitiveTokens.amber500.withValues(alpha: 0.2)
                                        : theme.colorScheme.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: index == 0
                                          ? AppPrimitiveTokens.amber700
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    prod.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${prod.totalRevenue.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      '${StringsManager.reportsSoldUnit.lang}: ${prod.soldQuantity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Export Button
                    AppButton(
                      text: StringsManager.reportsExport.lang,
                      icon: AppIcons.pdf,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(StringsManager.reportsExportPdfSuccess.lang)),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodTab(String key, String title) {
    final theme = Theme.of(context);
    final isSelected = _selectedPeriod == key;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = key;
          });
          context.read<ReportsBloc>().add(LoadReportsSummaryEvent(period: key));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required String value,
    required Color color,
    required dynamic icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              AppIcon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(ThemeData theme, {required String label, required double heightPercent, bool isHighest = false}) {
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
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
