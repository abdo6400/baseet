import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_search_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/customers_list/customers_list_bloc.dart';
import '../blocs/customers_list/customers_list_event.dart';
import '../blocs/customers_list/customers_list_state.dart';
import '../widgets/customer_ledger_card.dart';
import '../widgets/debt_filter_chips_row.dart';
import '../widgets/debt_summary_carousel.dart';

class DebtLedgerPage extends StatefulWidget {
  const DebtLedgerPage({super.key});

  @override
  State<DebtLedgerPage> createState() => _DebtLedgerPageState();
}

class _DebtLedgerPageState extends State<DebtLedgerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          style: context.label(
            22,
            weight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.user, color: theme.colorScheme.primary),
            onPressed: () => context.push(AppRoutes.addCustomer),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_debt_ledger_add_customer',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.addCustomer),
        icon: const AppIcon(AppIcons.add, color: Colors.white),
        label: Text(
          StringsManager.debtsAddCustomer.lang,
          style: context.label(14, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: BlocBuilder<CustomersListBloc, CustomersListState>(
        builder: (context, state) {
          if (state.status == CustomersListStatus.loading && state.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(context.safeDp(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header
                        Text(
                          StringsManager.debtsTitle.lang,
                          style: context.label(20, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          StringsManager.debtsSubtitle.lang,
                          style: context.label(
                            13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        14.vSpace,

                        // Search Bar
                        AppSearchField(
                          controller: _searchController,
                          hint: StringsManager.debtsSearchCustomer.lang,
                          onChanged: (q) {
                            context.read<CustomersListBloc>().add(SearchCustomersEvent(q));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary Carousel
                SliverToBoxAdapter(
                  child: DebtSummaryCarousel(
                    totalDebt: state.totalDebt,
                    overdueDebt: state.overdueDebt,
                    todayCollections: state.todayCollections,
                  ),
                ),

                // Status Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: DebtFilterChipsRow(
                      selectedStatus: state.statusFilter,
                      sortByHighest: state.sortByHighest,
                      onFilterSelected: (status, sortByHighest) {
                        context.read<CustomersListBloc>().add(FilterCustomersByStatusEvent(
                              status: status,
                              sortByHighest: sortByHighest,
                            ));
                      },
                    ),
                  ),
                ),

                // Customer Cards List
                if (state.customers.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: EmptyStateWidget(
                        title: StringsManager.commonEmpty.lang,
                        subtitle: StringsManager.debtsNoCustomersFound.lang,
                        icon: AppIcons.users,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final customer = state.customers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomerLedgerCard(
                              customer: customer,
                              onTap: () {
                                context.push(AppRoutes.customerStatementPath(customer.id));
                              },
                              onVoucherTap: () {
                                context.push(AppRoutes.paymentVoucherPath(customerId: customer.id));
                              },
                            ),
                          );
                        },
                        childCount: state.customers.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
