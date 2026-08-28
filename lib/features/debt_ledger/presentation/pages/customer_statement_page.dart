import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_pdf_helper.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/debt_transaction_entity.dart';
import '../blocs/customer_statement/customer_statement_bloc.dart';
import '../blocs/customer_statement/customer_statement_event.dart';
import '../blocs/customer_statement/customer_statement_state.dart';
import '../widgets/customer_share_bottom_sheet.dart';
import '../widgets/customer_statement_actions.dart';
import '../widgets/customer_statement_profile_card.dart';
import '../widgets/customer_transaction_tile.dart';

class CustomerStatementPage extends StatefulWidget {
  final String customerId;

  const CustomerStatementPage({super.key, required this.customerId});

  @override
  State<CustomerStatementPage> createState() => _CustomerStatementPageState();
}

class _CustomerStatementPageState extends State<CustomerStatementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerStatementBloc>().add(LoadCustomerStatementEvent(widget.customerId));
  }

  void _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp(String phone, String name, double debt) async {
    final formattedDebt = debt.toStringAsFixed(debt.truncateToDouble() == debt ? 0 : 2);
    final message = Uri.encodeComponent(
      StringsManager.customerWhatsappReminder.trArgs(args: [name, formattedDebt]),
    );
    final url = Uri.parse('https://wa.me/20$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _printCustomerStatement(CustomerEntity customer, List<DebtTransactionEntity> transactions) async {
    final pdf = await AppPdfHelper.createDocument();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('${StringsManager.pdfCustomerStatementTitle.lang} - ${StringsManager.appName.lang}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.pdfCustomerName.lang}: ${customer.name}'),
                    pw.Text('${StringsManager.pdfCustomerPhone.lang}: ${customer.phone}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.pdfCurrentDebt.lang}: ${customer.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}'),
                    pw.Text('${StringsManager.pdfCreditLimit.lang}: ${customer.creditLimit.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}'),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Divider(),
                AppPdfHelper.fromRtlTextArray(
                  headers: [
                    StringsManager.pdfDate.lang,
                    StringsManager.pdfTransactionType.lang,
                    StringsManager.pdfDescription.lang,
                    StringsManager.pdfAmount.lang,
                    StringsManager.pdfRemainingBalance.lang,
                  ],
                  data: transactions.map((t) {
                    final isDebt = t.type == TransactionType.saleCredit;
                    final description = (t.itemsSummary != null && t.itemsSummary!.isNotEmpty)
                        ? t.itemsSummary!.join(', ')
                        : (t.notes ?? (isDebt ? StringsManager.pdfDefaultSaleNotes.lang : StringsManager.pdfDefaultVoucherNotes.lang));
                    return [
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                      isDebt ? StringsManager.pdfCreditSale.lang : StringsManager.pdfPaymentVoucher.lang,
                      description,
                      '${t.amount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${t.remainingBalance.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    ];
                  }).toList(),
                ),
              ],
            ),
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
      appBar: PageHeader(
        title: StringsManager.customerStatementTitle.lang,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: StringsManager.pdfPrintTooltip.lang,
            onPressed: () {
              final state = context.read<CustomerStatementBloc>().state;
              if (state.customer != null) {
                _printCustomerStatement(state.customer!, state.transactions);
              }
            },
          ),
          IconButton(
            icon: AppIcon(AppIcons.share),
            onPressed: () {
              final cust = context.read<CustomerStatementBloc>().state.customer;
              if (cust != null) {
                CustomerShareBottomSheet.show(
                  context,
                  customer: cust,
                  onWhatsAppShare: () => _openWhatsApp(cust.phone, cust.name, cust.totalDebt),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerStatementBloc, CustomerStatementState>(
        builder: (context, state) {
          if (state.status == CustomerStatementStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.customer == null) {
            return Center(
              child: Text(
                state.errorMessage ?? StringsManager.commonEmpty.lang,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }

          final customer = state.customer!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Profile Card
                CustomerStatementProfileCard(customer: customer),
                16.vSpace,

                // Action Buttons Bar
                CustomerStatementActions(
                  onCall: () => _callPhone(customer.phone),
                  onWhatsApp: () => _openWhatsApp(customer.phone, customer.name, customer.totalDebt),
                  onVoucher: () => context.push(AppRoutes.paymentVoucherPath(customerId: customer.id)),
                ),
                24.vSpace,

                // Transactions History Section Header
                Text(
                  StringsManager.customerTransactionsHistory.lang,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                12.vSpace,

                // Transactions List
                if (state.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: EmptyStateWidget(
                      title: StringsManager.commonEmpty.lang,
                      subtitle: StringsManager.customerNoTransactions.lang,
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.transactions.length,
                    separatorBuilder: (_, __) => 10.vSpace,
                    itemBuilder: (context, index) {
                      return CustomerTransactionTile(transaction: state.transactions[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
