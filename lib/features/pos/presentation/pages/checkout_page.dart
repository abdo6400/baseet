import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../config/database/local/mock_data.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_dropdown.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/form/receipt_attachment_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/catalog/pos_catalog_bloc.dart';
import '../blocs/catalog/pos_catalog_event.dart';
import '../blocs/checkout/checkout_bloc.dart';
import '../blocs/checkout/checkout_event.dart';
import '../blocs/checkout/checkout_state.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../widgets/checkout_order_summary_card.dart';
import '../widgets/payment_method_tile.dart';
import 'receipt_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _receiptPath;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == CheckoutStatus.submitting,
          isError: state.status == CheckoutStatus.error,
          isSuccess: state.status == CheckoutStatus.success,
          errorMessage: state.errorMessage,
          successMessage: StringsManager.checkoutSuccess.lang,
          onSuccess: () {
            final cartItems = List<CartItemEntity>.from(context.read<CartBloc>().state.items);
            final total = context.read<CartBloc>().state.totalPrice;
            final formValues = _formKey.currentState?.value;
            final paid = double.tryParse(formValues?['paid_amount']?.toString() ?? '') ?? total;
            final change = paid > total ? paid - total : 0.0;
            final methodStr = state.paymentMethod == PaymentMethod.cash
                ? 'نقدي'
                : (state.paymentMethod == PaymentMethod.card ? 'بطاقة' : 'آجل (دين)');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptPage(
                  orderId: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                  items: cartItems,
                  totalPrice: total,
                  paidAmount: paid,
                  changeAmount: change,
                  paymentMethod: methodStr,
                  timestamp: DateTime.now(),
                ),
              ),
            );
            context.read<CartBloc>().add(ClearCartEvent());
            context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
          },
        );
      },
      builder: (context, checkoutState) {
        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(16),
          appBar: PageHeader(
            title: StringsManager.checkoutTitle.lang,
            showBackButton: true,
          ),
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) {
                return EmptyStateWidget(
                  title: StringsManager.posEmptyCart.lang,
                  icon: AppIcons.cart,
                );
              }

              return AppForm(
                formKey: _formKey,
                initialValue: const {
                  'paid_amount': '0',
                  'notes': '',
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    CheckoutOrderSummaryCard(
                      totalPrice: cartState.totalPrice,
                      totalItemCount: cartState.totalItemCount,
                    ),
                    20.vSpace,

                    // Payment Method Selector
                    Text(
                      StringsManager.checkoutPaymentMethod.lang,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    12.vSpace,
                    Row(
                      children: [
                        PaymentMethodTile(
                          title: StringsManager.checkoutCash.lang,
                          method: PaymentMethod.cash,
                          icon: AppIcons.cash,
                          isSelected: checkoutState.paymentMethod == PaymentMethod.cash,
                          onSelected: (m) => context.read<CheckoutBloc>().add(SetPaymentMethodEvent(m)),
                        ),
                        8.hSpace,
                        PaymentMethodTile(
                          title: StringsManager.checkoutCard.lang,
                          method: PaymentMethod.card,
                          icon: AppIcons.card,
                          isSelected: checkoutState.paymentMethod == PaymentMethod.card,
                          onSelected: (m) => context.read<CheckoutBloc>().add(SetPaymentMethodEvent(m)),
                        ),
                        8.hSpace,
                        PaymentMethodTile(
                          title: StringsManager.checkoutDebt.lang,
                          method: PaymentMethod.debt,
                          icon: AppIcons.debts,
                          isSelected: checkoutState.paymentMethod == PaymentMethod.debt,
                          isDebt: true,
                          onSelected: (m) => context.read<CheckoutBloc>().add(SetPaymentMethodEvent(m)),
                        ),
                      ],
                    ),
                    20.vSpace,

                    // Customer Selection & Partial Debt Payment Section
                    if (checkoutState.paymentMethod == PaymentMethod.debt) ...[
                      AppFormDropdown<String>(
                        name: 'customer_id',
                        label: StringsManager.checkoutSelectCustomer.lang,
                        hint: StringsManager.checkoutSelectCustomer.lang,
                        items: BaseetMockData.initialCustomers.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text('${c.name} (${c.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang} ${StringsManager.debtsDebtSuffix.lang})'),
                          );
                        }).toList(),
                        validator: AppFormValidators.required(),
                        onChanged: (val) {
                          if (val != null) {
                            final cust = BaseetMockData.initialCustomers.firstWhere((c) => c.id == val);
                            context.read<CheckoutBloc>().add(SelectCustomerForDebtEvent(
                                  customerId: cust.id,
                                  customerName: cust.name,
                                ));
                          }
                        },
                      ),
                      14.vSpace,

                      // Partial payment input for debt
                      AppFormTextField(
                        name: 'paid_amount',
                        label: StringsManager.checkoutReceivedAmount.lang,
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                        validator: AppFormValidators.numeric(),
                        onChanged: (val) {
                          final amount = double.tryParse(val ?? '0') ?? 0.0;
                          context.read<CheckoutBloc>().add(SetPaidAmountEvent(amount));
                        },
                      ),
                      14.vSpace,
                    ],

                    // Notes Field
                    AppFormTextField(
                      name: 'notes',
                      label: StringsManager.checkoutNotes.lang,
                      hint: StringsManager.checkoutNotesHint.lang,
                      maxLines: 2,
                    ),
                    16.vSpace,

                    // Receipt Attachment Field
                    ReceiptAttachmentField(
                      receiptPath: _receiptPath,
                      onChanged: (path) => setState(() => _receiptPath = path),
                    ),
                    30.vSpace,

                    // Confirm Button
                    AppButton(
                      text: StringsManager.checkoutConfirm.lang,
                      icon: AppIcons.check,
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final formValues = _formKey.currentState!.value;
                          context.read<CheckoutBloc>().add(SubmitCheckoutEvent(
                                items: cartState.items,
                                totalAmount: cartState.totalPrice,
                                notes: formValues['notes']?.toString() ?? '',
                                receiptPath: _receiptPath,
                              ));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
