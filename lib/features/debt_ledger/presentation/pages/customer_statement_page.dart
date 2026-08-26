import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/feedback/status_badge.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/common/widgets/scanner/receipt_preview_dialog.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/customer_statement/customer_statement_bloc.dart';
import '../blocs/customer_statement/customer_statement_event.dart';
import '../blocs/customer_statement/customer_statement_state.dart';

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
            icon: AppIcon(AppIcons.share),
            onPressed: () {
              final cust = context.read<CustomerStatementBloc>().state.customer;
              if (cust != null) {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (modalContext) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.customerStatementShare.lang,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'كشف حساب العميل: ${cust.name}\nإجمالي الدين: ${cust.totalDebt} ${StringsManager.posCurrency.lang}\nرقم الهاتف: ${cust.phone}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: AppIcon(AppIcons.whatsapp, color: AppPrimitiveTokens.emerald700),
                          title: Text(StringsManager.customerWhatsapp.lang),
                          onTap: () {
                            Navigator.pop(modalContext);
                            _openWhatsApp(cust.phone, cust.name, cust.totalDebt);
                          },
                        ),
                      ],
                    ),
                  ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                customer.phone,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(
                            label: customer.isOverdue
                                ? StringsManager.debtsStatusOverdue.lang
                                : StringsManager.debtsStatusRegular.lang,
                            variant: customer.isOverdue
                                ? StatusBadgeVariant.error
                                : StatusBadgeVariant.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
                      const SizedBox(height: 16),

                      // Balance & Limit Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringsManager.customerTotalBalance.lang,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: customer.totalDebt > 0
                                      ? AppPrimitiveTokens.red700
                                      : AppPrimitiveTokens.emerald700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                StringsManager.customerCreditLimit.lang,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.creditLimit.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Credit Limit Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: customer.limitUsagePercent,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            customer.isLimitExceeded
                                ? AppPrimitiveTokens.red700
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons Bar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () => _callPhone(customer.phone),
                        icon: AppIcon(AppIcons.phone, size: 18),
                        label: Text(StringsManager.customerCall.lang),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () => _openWhatsApp(customer.phone, customer.name, customer.totalDebt),
                        icon: AppIcon(AppIcons.whatsapp, size: 18, color: Colors.green),
                        label: Text(StringsManager.customerWhatsapp.lang),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () {
                          context.push(AppRoutes.paymentVoucherPath(customerId: customer.id));
                        },
                        icon: AppIcon(AppIcons.receipt, size: 18, color: Colors.white),
                        label: Text(StringsManager.debtsActionVoucher.lang),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Transactions History Section Header
                Text(
                  StringsManager.customerTransactionsHistory.lang,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),

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
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      final isPayment = tx.type == TransactionType.paymentVoucher;
                      final accentColor = isPayment ? AppPrimitiveTokens.emerald700 : AppPrimitiveTokens.red700;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                isPayment ? AppIcons.payments : AppIcons.receipt,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPayment ? StringsManager.customerTypePayment.lang : StringsManager.customerTypeSale.lang,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (tx.notes != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.notes!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      if (tx.receiptPath != null && tx.receiptPath!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => ReceiptPreviewDialog.show(
                                            context,
                                            imagePath: tx.receiptPath!,
                                            title: StringsManager.receiptView.lang,
                                          ),
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppRadius.sm),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                AppIcon(AppIcons.receipt, size: 10, color: theme.colorScheme.primary),
                                                const SizedBox(width: 3),
                                                Text(
                                                  StringsManager.receiptView.lang,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPayment ? "-" : "+"}${tx.amount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${StringsManager.customerTotalBalance.lang}: ${tx.remainingBalance.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
