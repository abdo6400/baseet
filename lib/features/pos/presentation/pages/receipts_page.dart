import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_search_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/receipts/pos_receipts_bloc.dart';
import '../blocs/receipts/pos_receipts_event.dart';
import '../blocs/receipts/pos_receipts_state.dart';
import '../widgets/receipt_card.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PosReceiptsBloc>().add(const LoadReceiptsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );

    if (picked != null && mounted) {
      final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

      context.read<PosReceiptsBloc>().add(FilterReceiptsByDateEvent(
            filter: ReceiptDateFilter.custom,
            customStartDate: start,
            customEndDate: end,
          ));
    }
  }

  String _getFilterTitle(ReceiptDateFilter filter) {
    switch (filter) {
      case ReceiptDateFilter.all:
        return StringsManager.receiptsFilterAll.lang;
      case ReceiptDateFilter.today:
        return StringsManager.receiptsFilterToday.lang;
      case ReceiptDateFilter.yesterday:
        return StringsManager.receiptsFilterYesterday.lang;
      case ReceiptDateFilter.thisWeek:
        return StringsManager.receiptsFilterThisWeek.lang;
      case ReceiptDateFilter.thisMonth:
        return StringsManager.receiptsFilterThisMonth.lang;
      case ReceiptDateFilter.custom:
        return StringsManager.receiptsFilterCustom.lang;
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
        title: Text(
          StringsManager.receiptsListTitle.lang,
          style: context.label(18, weight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.refresh, size: 20),
            onPressed: () {
              context.read<PosReceiptsBloc>().add(const LoadReceiptsEvent());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      body: BlocBuilder<PosReceiptsBloc, PosReceiptsState>(
        builder: (context, state) {
          final filterChips = [
            ReceiptDateFilter.all,
            ReceiptDateFilter.today,
            ReceiptDateFilter.yesterday,
            ReceiptDateFilter.thisWeek,
            ReceiptDateFilter.thisMonth,
            ReceiptDateFilter.custom,
          ];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      AppSearchField(
                        controller: _searchController,
                        hint: StringsManager.receiptsSearchHint.lang,
                        onChanged: (q) {
                          context.read<PosReceiptsBloc>().add(SearchReceiptsEvent(q));
                        },
                      ),
                      12.vSpace,

                      // Date Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filterChips.map((filter) {
                            final isSelected = state.dateFilter == filter;
                            final title = _getFilterTitle(filter);

                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(title),
                                selected: isSelected,
                                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: context.label(
                                  12,
                                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                                onSelected: (_) {
                                  if (filter == ReceiptDateFilter.custom) {
                                    _pickCustomDateRange();
                                  } else {
                                    context
                                        .read<PosReceiptsBloc>()
                                        .add(FilterReceiptsByDateEvent(filter: filter));
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      12.vSpace,

                      // Financial & Invoices Stats Summary Card
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.safeDp(14),
                          vertical: context.safeDp(10),
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AppIcon(
                                  AppIcons.receipt,
                                  size: context.safeDp(20),
                                  color: theme.colorScheme.primary,
                                ),
                                8.hSpace,
                                Text(
                                  '${StringsManager.receiptsCount.lang}: ',
                                  style: context.label(
                                    13,
                                    weight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${state.totalCount}',
                                  style: context.label(
                                    14,
                                    weight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${StringsManager.receiptsTotalSales.lang}: ',
                                  style: context.label(
                                    13,
                                    weight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${state.totalSales.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                  style: context.label(
                                    15,
                                    weight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Receipts List
              if (state.status == PosReceiptsStatus.loading && state.orders.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (state.orders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: EmptyStateWidget(
                      title: StringsManager.commonEmpty.lang,
                      subtitle: StringsManager.receiptsNoFound.lang,
                      icon: AppIcons.receipt,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = state.orders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReceiptCard(order: order),
                        );
                      },
                      childCount: state.orders.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
