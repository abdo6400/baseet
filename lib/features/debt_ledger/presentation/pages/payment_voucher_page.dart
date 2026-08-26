import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/database/local/mock_data.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/common/widgets/form/receipt_attachment_field.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/customers_list/customers_list_bloc.dart';
import '../blocs/customers_list/customers_list_event.dart';
import '../blocs/payment_voucher/payment_voucher_bloc.dart';
import '../blocs/payment_voucher/payment_voucher_event.dart';
import '../blocs/payment_voucher/payment_voucher_state.dart';

class PaymentVoucherPage extends StatefulWidget {
  final String? customerId;

  const PaymentVoucherPage({super.key, this.customerId});

  @override
  State<PaymentVoucherPage> createState() => _PaymentVoucherPageState();
}

class _PaymentVoucherPageState extends State<PaymentVoucherPage> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCustomerId;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.customerId;
    if (_selectedCustomerId != null) {
      context.read<PaymentVoucherBloc>().add(SelectVoucherCustomerEvent(_selectedCustomerId!));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringsManager.checkoutErrorSelectCustomer.lang)),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringsManager.voucherErrorInvalidAmount.lang)),
      );
      return;
    }

    context.read<PaymentVoucherBloc>().add(SubmitPaymentVoucherEvent(
          customerId: _selectedCustomerId!,
          amount: amount,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          receiptPath: _receiptPath,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PaymentVoucherBloc, PaymentVoucherState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == PaymentVoucherStatus.submitting,
          isError: state.status == PaymentVoucherStatus.error,
          isSuccess: state.status == PaymentVoucherStatus.success,
          errorMessage: state.errorMessage,
          successMessage: StringsManager.voucherSuccess.lang,
          onSuccess: () {
            context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
            context.pop();
          },
        );
      },
      builder: (context, state) {
        final currentCustomer = state.selectedCustomer ??
            (_selectedCustomerId != null
                ? BaseetMockData.initialCustomers.firstWhere(
                    (c) => c.id == _selectedCustomerId,
                    orElse: () => BaseetMockData.initialCustomers.first,
                  )
                : null);

        final double currentDebt = currentCustomer?.totalDebt ?? 0.0;
        final double enteredAmount = state.amount;
        final double remaining = (currentDebt - enteredAmount).clamp(0.0, 999999.0);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PageHeader(
            title: StringsManager.voucherTitle.lang,
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Selector
                Text(
                  StringsManager.voucherCustomer.lang,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(StringsManager.voucherSelectCustomer.lang),
                      value: _selectedCustomerId,
                      items: BaseetMockData.initialCustomers.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('${c.name} (${StringsManager.debtsDebtSuffix.lang}: ${c.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCustomerId = val;
                          });
                          context.read<PaymentVoucherBloc>().add(SelectVoucherCustomerEvent(val));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Current Debt Display Card
                if (currentCustomer != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppPrimitiveTokens.red700.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppPrimitiveTokens.red700.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${StringsManager.debtsTotal.lang}:',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${currentDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppPrimitiveTokens.red700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amount input
                AppTextField(
                  controller: _amountController,
                  label: StringsManager.voucherAmount.lang,
                  hint: '0.0',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final amount = double.tryParse(val) ?? 0.0;
                    context.read<PaymentVoucherBloc>().add(SetVoucherAmountEvent(amount));
                  },
                ),
                const SizedBox(height: 16),

                // Remaining Debt preview
                if (currentCustomer != null && enteredAmount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppPrimitiveTokens.emerald700.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppPrimitiveTokens.emerald700.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          StringsManager.voucherRemaining.lang,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${remaining.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppPrimitiveTokens.emerald700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes
                AppTextField(
                  controller: _notesController,
                  label: StringsManager.voucherNotes.lang,
                  hint: StringsManager.voucherNotesHint.lang,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Receipt Attachment
                ReceiptAttachmentField(
                  receiptPath: _receiptPath,
                  onChanged: (p) => setState(() => _receiptPath = p),
                ),
                const SizedBox(height: 32),

                // Save button
                AppButton(
                  text: StringsManager.voucherSave.lang,
                  icon: AppIcons.receipt,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
