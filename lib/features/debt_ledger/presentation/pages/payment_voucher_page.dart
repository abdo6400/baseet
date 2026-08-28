import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_dropdown.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/form/receipt_attachment_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/customer_entity.dart';
import '../blocs/customers_list/customers_list_bloc.dart';
import '../blocs/customers_list/customers_list_event.dart';
import '../blocs/customers_list/customers_list_state.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
    if (widget.customerId != null) {
      context.read<PaymentVoucherBloc>().add(SelectVoucherCustomerEvent(widget.customerId!));
    }
  }

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final customerId = values['customer_id']?.toString();
      final amount = double.tryParse(values['amount']?.toString() ?? '0') ?? 0.0;
      final notes = (values['notes'] as String?)?.trim();

      if (customerId == null || customerId.isEmpty) {
        context.showStateHandler(
          isLoading: false,
          isError: true,
          errorMessage: StringsManager.checkoutErrorSelectCustomer.lang,
        );
        return;
      }

      if (amount <= 0) {
        context.showStateHandler(
          isLoading: false,
          isError: true,
          errorMessage: StringsManager.voucherErrorInvalidAmount.lang,
        );
        return;
      }

      context.read<PaymentVoucherBloc>().add(SubmitPaymentVoucherEvent(
            customerId: customerId,
            amount: amount,
            notes: notes?.isNotEmpty == true ? notes : null,
            receiptPath: _receiptPath,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        CustomerEntity? currentCustomer = state.selectedCustomer;
        if (currentCustomer == null && widget.customerId != null) {
          final customers = context.read<CustomersListBloc>().state.customers;
          currentCustomer = customers.where((c) => c.id == widget.customerId).firstOrNull;
        }

        final double currentDebt = currentCustomer?.totalDebt ?? 0.0;
        final double enteredAmount = state.amount;
        final double remaining = (currentDebt - enteredAmount).clamp(0.0, 999999.0);

        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          appBar: PageHeader(
            title: StringsManager.voucherTitle.lang,
            showBackButton: true,
          ),
          child: AppForm(
            formKey: _formKey,
            initialValue: {
              if (widget.customerId != null) 'customer_id': widget.customerId,
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Selector
                BlocBuilder<CustomersListBloc, CustomersListState>(
                  builder: (context, custState) {
                    return AppFormDropdown<String>(
                      name: 'customer_id',
                      label: StringsManager.voucherCustomer.lang,
                      hint: StringsManager.voucherSelectCustomer.lang,
                      items: custState.customers.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('${c.name} (${StringsManager.debtsDebtSuffix.lang}: ${c.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang})'),
                        );
                      }).toList(),
                      validator: AppFormValidators.required(),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<PaymentVoucherBloc>().add(SelectVoucherCustomerEvent(val));
                        }
                      },
                    );
                  },
                ),
                16.vSpace,

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
                  16.vSpace,
                ],

                // Amount input
                AppFormTextField(
                  name: 'amount',
                  label: StringsManager.voucherAmount.lang,
                  hint: '0.0',
                  keyboardType: TextInputType.number,
                  validator: AppFormValidators.compose([
                    AppFormValidators.required(),
                    AppFormValidators.numeric(),
                  ]),
                  onChanged: (val) {
                    final amount = double.tryParse(val ?? '0') ?? 0.0;
                    context.read<PaymentVoucherBloc>().add(SetVoucherAmountEvent(amount));
                  },
                ),
                16.vSpace,

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
                  16.vSpace,
                ],

                // Notes
                AppFormTextField(
                  name: 'notes',
                  label: StringsManager.voucherNotes.lang,
                  hint: StringsManager.voucherNotesHint.lang,
                  maxLines: 2,
                ),
                16.vSpace,

                // Receipt Attachment
                ReceiptAttachmentField(
                  receiptPath: _receiptPath,
                  onChanged: (p) => setState(() => _receiptPath = p),
                ),
                24.vSpace,

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
