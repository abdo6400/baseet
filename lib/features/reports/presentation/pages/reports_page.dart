import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../blocs/reports/reports_bloc.dart';
import '../blocs/reports/reports_event.dart';
import '../blocs/reports/reports_state.dart';
import '../widgets/report_metric_card.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/report_sales_chart_card.dart';
import '../widgets/report_top_products_card.dart';

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
    context
        .read<ReportsBloc>()
        .add(LoadReportsSummaryEvent(period: _selectedPeriod));
  }

  Future<void> _exportPdfReport(ReportSummaryEntity summary) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('تقرير المبيعات والأرباح - بسيط',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'إجمالي المبيعات: ${summary.totalSales.toStringAsFixed(0)} ج.م'),
                  pw.Text(
                      'صافي الأرباح: ${summary.netProfit.toStringAsFixed(0)} ج.م'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'المبيعات النقدية: ${summary.cashSales.toStringAsFixed(0)} ج.م'),
                  pw.Text(
                      'المبيعات الآجلة (ديون): ${summary.debtSales.toStringAsFixed(0)} ج.م'),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.Text('المنتجات الأكثر مبيعاً',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['المنتج', 'الكمية المباعة', 'إجمالي الإيرادات'],
                data: summary.topProducts
                    .map((p) => [
                          p.productName,
                          '${p.soldQuantity}',
                          '${p.totalRevenue.toStringAsFixed(0)} ج.م',
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
          child:
              Container(color: theme.colorScheme.outlineVariant, height: 1.0),
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
              context
                  .read<ReportsBloc>()
                  .add(LoadReportsSummaryEvent(period: _selectedPeriod));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Text(
                    StringsManager.reportsTitle.lang,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  2.vSpace,
                  Text(
                    StringsManager.reportsSubtitle.lang,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  14.vSpace,

                  // Period Tabs
                  ReportPeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    onPeriodSelected: (key) {
                      setState(() => _selectedPeriod = key);
                      context
                          .read<ReportsBloc>()
                          .add(LoadReportsSummaryEvent(period: key));
                    },
                  ),
                  16.vSpace,

                  if (summary != null) ...[
                    // Primary Metric: Net Profit Hero
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                StringsManager.reportsNetProfit.lang,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const AppIcon(AppIcons.trendingUp,
                                    color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                          4.vSpace,
                          Text(
                            '${summary.netProfit.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          12.vSpace,
                          Row(
                            children: [
                              Text(
                                '${StringsManager.reportsTotalSales.lang}: ',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              Text(
                                '${summary.totalSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    14.vSpace,

                    // Cash vs Debt Row
                    Row(
                      children: [
                        Expanded(
                          child: ReportMetricCard(
                            title: StringsManager.reportsCashCollected.lang,
                            value:
                                '${summary.cashSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: AppPrimitiveTokens.emerald700,
                            icon: AppIcons.payments,
                          ),
                        ),
                        12.hSpace,
                        Expanded(
                          child: ReportMetricCard(
                            title: StringsManager.reportsDebtSales.lang,
                            value:
                                '${summary.debtSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            color: AppPrimitiveTokens.red700,
                            icon: AppIcons.debts,
                          ),
                        ),
                      ],
                    ),
                    24.vSpace,

                    // Sales Visual Overview
                    ReportSalesChartCard(
                        totalInvoicesCount: summary.totalInvoicesCount),
                    24.vSpace,

                    // Top Selling Products Leaderboard
                    ReportTopProductsCard(products: summary.topProducts),
                    24.vSpace,

                    // Export Button
                    AppButton(
                      text: StringsManager.reportsExport.lang,
                      icon: AppIcons.pdf,
                      onPressed: () async {
                        await _exportPdfReport(summary);
                        if (context.mounted) {
                          context.showStateHandler(
                            isLoading: false,
                            isSuccess: true,
                            successMessage:
                                StringsManager.reportsExportPdfSuccess.lang,
                          );
                        }
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
}
