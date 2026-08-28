import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_dropdown.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/form/receipt_attachment_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_event.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_state.dart';
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
  void initState() {
    super.initState();
    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
  }

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
                ? StringsManager.checkoutCash.lang
                : (state.paymentMethod == PaymentMethod.card
                    ? StringsManager.checkoutCard.lang
                    : StringsManager.checkoutDebt.lang);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptPage(
                  orderId: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                  items: cartItems,
                  totalPrice: total,
                  paidAmount: paid,
                  changeAmount: change,
                  customerName: state.customerName,
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
          padding: EdgeInsets.all(context.safeDp(AppSpacing.md)),
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  CheckoutOrderSummaryCard(
                    totalPrice: cartState.totalPrice,
                    totalItemCount: cartState.totalItemCount,
                    items: cartState.items,
                    onIncrement: (item) {
                      context.read<CartBloc>().add(AddProductToCartEvent(item.product));
                    },
                    onDecrement: (item) {
                      if (item.quantity > 1) {
                        context.read<CartBloc>().add(UpdateItemQuantityEvent(item.product.id, item.quantity - 1));
                      } else {
                        context.read<CartBloc>().add(RemoveProductFromCartEvent(item.product.id));
                      }
                    },
                    onRemove: (item) {
                      context.read<CartBloc>().add(RemoveProductFromCartEvent(item.product.id));
                    },
                  ),
                  20.vSpace,

                  // Payment Form
                  AppForm(
                    formKey: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.checkoutPaymentMethod.lang,
                          style: context.label(
                            15,
                            weight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        12.vSpace,

                        // Payment Method Tiles
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

                        // Customer Selection Section (Available for ALL payment methods)
                        BlocBuilder<CustomersListBloc, CustomersListState>(
                          builder: (context, custState) {
                            final isDebt = checkoutState.paymentMethod == PaymentMethod.debt;
                            return AppFormDropdown<String>(
                              name: 'customer_id',
                              label: isDebt
                                  ? StringsManager.checkoutSelectCustomer.lang
                                  : '${StringsManager.checkoutCustomer.lang} (${StringsManager.commonOptional.lang})',
                              hint: StringsManager.checkoutSelectCustomer.lang,
                              items: custState.customers.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text('${c.name} (${c.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang} ${StringsManager.debtsDebtSuffix.lang})'),
                                );
                              }).toList(),
                              validator: isDebt ? AppFormValidators.required() : null,
                              onChanged: (val) {
                                if (val != null && val.isNotEmpty) {
                                  final cust = custState.customers.where((c) => c.id == val).firstOrNull;
                                  if (cust != null) {
                                    context.read<CheckoutBloc>().add(SelectCustomerForDebtEvent(
                                          customerId: cust.id,
                                          customerName: cust.name,
                                        ));
                                  }
                                } else {
                                  context.read<CheckoutBloc>().add(const SelectCustomerForDebtEvent(
                                        customerId: null,
                                        customerName: null,
                                      ));
                                }
                              },
                            );
                          },
                        ),
                        14.vSpace,

                        // Partial debt payment input if payment method is Debt
                        if (checkoutState.paymentMethod == PaymentMethod.debt) ...[
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
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
