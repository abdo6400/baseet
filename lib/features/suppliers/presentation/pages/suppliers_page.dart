import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_search_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/suppliers/suppliers_bloc.dart';
import '../blocs/suppliers/suppliers_event.dart';
import '../blocs/suppliers/suppliers_state.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_summary_banner.dart';
import 'add_supplier_page.dart';
import 'add_supplier_invoice_page.dart';
import 'supplier_statement_page.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SuppliersBloc>()..add(const LoadSuppliersEvent()),
      child: const _SuppliersView(),
    );
  }
}

class _SuppliersView extends StatefulWidget {
  const _SuppliersView();

  @override
  State<_SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<_SuppliersView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp(String phone, String name) async {
    final message = Uri.encodeComponent('مرحباً أ/ $name، بخصوص طلبية التوريد من تطبيق بسيط');
    final url = Uri.parse('https://wa.me/20$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PageHeader(
        title: StringsManager.suppliersTitle.lang,
        showBackButton: true,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.add, size: 22, color: theme.colorScheme.onSurface),
            tooltip: StringsManager.suppliersAddSupplier.lang,
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSupplierPage()),
              );
              if (added != null && context.mounted) {
                context.read<SuppliersBloc>().add(const LoadSuppliersEvent());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<SuppliersBloc, SuppliersState>(
        builder: (context, state) {
          if (state.status == SuppliersStatus.loading && state.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SuppliersStatus.error && state.suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? StringsManager.commonError.lang),
                  16.vSpace,
                  ElevatedButton(
                    onPressed: () => context.read<SuppliersBloc>().add(const LoadSuppliersEvent()),
                    child: Text(StringsManager.commonRetry.lang),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SuppliersBloc>().add(const LoadSuppliersEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Top Summary Card
                  SupplierSummaryBanner(
                    totalDebt: state.totalDebt,
                    suppliersCount: state.suppliers.length,
                  ),
                  16.vSpace,

                  // Search Bar
                  AppSearchField(
                    controller: _searchController,
                    hint: StringsManager.suppliersSearchHint.lang,
                    onChanged: (val) => context.read<SuppliersBloc>().add(SearchSuppliersEvent(val)),
                  ),
                  16.vSpace,

                  // Suppliers List or EmptyStateWidget
                  if (state.suppliers.isEmpty)
                    EmptyStateWidget(
                      title: StringsManager.suppliersNoFound.lang,
                      icon: AppIcons.user,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.suppliers.length,
                      separatorBuilder: (_, __) => 12.vSpace,
                      itemBuilder: (context, index) {
                        final sup = state.suppliers[index];
                        return SupplierCard(
                          supplier: sup,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SupplierStatementPage(supplier: sup),
                              ),
                            );
                            if (context.mounted) {
                              context.read<SuppliersBloc>().add(const LoadSuppliersEvent());
                            }
                          },
                          onInvoiceTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddSupplierInvoicePage(supplier: sup),
                              ),
                            );
                            if (result != null && context.mounted) {
                              context.read<SuppliersBloc>().add(const LoadSuppliersEvent());
                            }
                          },
                          onPhoneTap: () => _callPhone(sup.phone),
                          onWhatsAppTap: () => _openWhatsApp(sup.phone, sup.name),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
