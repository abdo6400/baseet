import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_invoice_entity.dart';
import '../blocs/supplier_statement/supplier_statement_bloc.dart';
import '../blocs/supplier_statement/supplier_statement_event.dart';
import '../blocs/supplier_statement/supplier_statement_state.dart';
import '../utils/supplier_pdf_helper.dart';
import '../widgets/supplier_info_header.dart';
import '../widgets/supplier_invoice_card.dart';
import 'add_supplier_invoice_page.dart';

class SupplierStatementPage extends StatelessWidget {
  final SupplierEntity supplier;

  const SupplierStatementPage({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupplierStatementBloc>()..add(LoadSupplierStatementEvent(supplier.id)),
      child: _SupplierStatementView(supplier: supplier),
    );
  }
}

class _SupplierStatementView extends StatefulWidget {
  final SupplierEntity supplier;

  const _SupplierStatementView({required this.supplier});

  @override
  State<_SupplierStatementView> createState() => _SupplierStatementViewState();
}

class _SupplierStatementViewState extends State<_SupplierStatementView> {
  late SupplierEntity _currentSupplier;

  @override
  void initState() {
    super.initState();
    _currentSupplier = widget.supplier;
  }

  Future<void> _printStatement(List<SupplierInvoiceEntity> invoices) async {
    await Printing.layoutPdf(
      onLayout: (format) async => SupplierPdfHelper.generateStatementPdf(
        supplier: _currentSupplier,
        invoices: invoices,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SupplierStatementBloc, SupplierStatementState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: false,
          isError: state.status == SupplierStatementStatus.error,
          errorMessage: state.errorMessage,
        );
      },
      builder: (context, state) {
        final invoices = state.invoices;

        return AppPageWrapper(
          scrollable: true,
          padding: EdgeInsets.all(context.safeDp(AppSpacing.md)),
          appBar: PageHeader(
            title: StringsManager.suppliersStatementTitle.lang,
            showBackButton: true,
            actions: [
              IconButton(
                icon: AppIcon(AppIcons.printer, size: 20),
                tooltip: StringsManager.customerPrintPdf.lang,
                onPressed: () => _printStatement(invoices),
              ),
            ],
          ),
          child: state.status == SupplierStatementStatus.loading && invoices.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Info Header
                    SupplierInfoHeader(supplier: _currentSupplier),
                    16.vSpace,

                    // Add Invoice Button
                    AppButton(
                      text: StringsManager.suppliersAddInvoice.lang,
                      icon: AppIcons.add,
                      onPressed: () async {
                        final newInvoice = await Navigator.push<SupplierInvoiceEntity>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddSupplierInvoicePage(supplier: _currentSupplier),
                          ),
                        );
                        if (newInvoice != null && context.mounted) {
                          context.read<SupplierStatementBloc>().add(
                                AddInvoiceToStatementEvent(newInvoice),
                              );
                          setState(() {
                            _currentSupplier = SupplierEntity(
                              id: _currentSupplier.id,
                              name: _currentSupplier.name,
                              companyName: _currentSupplier.companyName,
                              phone: _currentSupplier.phone,
                              address: _currentSupplier.address,
                              totalDebt: _currentSupplier.totalDebt + newInvoice.remainingAmount,
                              lastTransactionDate: DateTime.now(),
                            );
                          });
                        }
                      },
                    ),
                    24.vSpace,

                    // Invoices Header
                    Text(
                      '${StringsManager.suppliersInvoicesHistory.lang} (${invoices.length})',
                      style: context.label(
                        16,
                        weight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    8.vSpace,

                    // Invoices List
                    if (invoices.isEmpty)
                      EmptyStateWidget(
                        title: StringsManager.commonEmpty.lang,
                        icon: AppIcons.inventory,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: invoices.length,
                        separatorBuilder: (_, __) => 12.vSpace,
                        itemBuilder: (context, index) {
                          return SupplierInvoiceCard(
                            invoice: invoices[index],
                            onTap: () async {
                              await Printing.layoutPdf(
                                onLayout: (format) async => SupplierPdfHelper.generateInvoicePdf(
                                  invoice: invoices[index],
                                  supplier: _currentSupplier,
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }
}
