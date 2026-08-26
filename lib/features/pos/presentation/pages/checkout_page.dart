import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/database/local/mock_data.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/common/widgets/form/receipt_attachment_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
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

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  String? _receiptPath;

  @override
  void dispose() {
    _notesController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == CheckoutStatus.submitting,
          isError: state.status == CheckoutStatus.error,
          isSuccess: state.status == CheckoutStatus.success,
          errorMessage: state.errorMessage,
          successMessage: StringsManager.checkoutSuccess.lang,
          onSuccess: () {
            context.read<CartBloc>().add(ClearCartEvent());
            context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
            context.pop();
          },
        );
      },
      builder: (context, checkoutState) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PageHeader(
            title: StringsManager.checkoutTitle.lang,
            showBackButton: true,
          ),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.isEmpty) {
                return Center(
                  child: Text(
                    StringsManager.posEmptyCart.lang,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Box
                    Text(
                      StringsManager.checkoutOrderSummary.lang,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartState.items.length,
                        separatorBuilder: (_, __) => Divider(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.product.sellPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: AppIcon(AppIcons.delete, size: 18, color: theme.colorScheme.error),
                                      onPressed: () {
                                        context.read<CartBloc>().add(UpdateItemQuantityEvent(
                                              item.product.id,
                                              item.quantity - 1,
                                            ));
                                      },
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      icon: AppIcon(AppIcons.add, size: 18, color: theme.colorScheme.primary),
                                      onPressed: () {
                                        context.read<CartBloc>().add(UpdateItemQuantityEvent(
                                              item.product.id,
                                              item.quantity + 1,
                                            ));
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            StringsManager.posTotal.lang,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${cartState.totalPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method
                    Text(
                      StringsManager.checkoutPaymentMethod.lang,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPaymentMethodOption(
                          context,
                          title: StringsManager.checkoutCash.lang,
                          method: PaymentMethod.cash,
                          icon: AppIcons.payments,
                          selected: checkoutState.paymentMethod == PaymentMethod.cash,
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentMethodOption(
                          context,
                          title: StringsManager.checkoutDebt.lang,
                          method: PaymentMethod.debt,
                          icon: AppIcons.debts,
                          selected: checkoutState.paymentMethod == PaymentMethod.debt,
                          isDebt: true,
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentMethodOption(
                          context,
                          title: StringsManager.checkoutCard.lang,
                          method: PaymentMethod.card,
                          icon: AppIcons.wallet,
                          selected: checkoutState.paymentMethod == PaymentMethod.card,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // If Debt is selected, show Customer dropdown
                    if (checkoutState.paymentMethod == PaymentMethod.debt) ...[
                      Text(
                        StringsManager.checkoutCustomer.lang,
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
                            hint: Text(StringsManager.checkoutSelectCustomer.lang),
                            value: checkoutState.customerId,
                            items: BaseetMockData.initialCustomers.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Text('${c.name} (${c.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang} ${StringsManager.debtsDebtSuffix.lang})'),
                              );
                            }).toList(),
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
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Partial payment input for debt
                      AppTextField(
                        controller: _paidAmountController,
                        label: StringsManager.checkoutReceivedAmount.lang,
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final amount = double.tryParse(val) ?? 0.0;
                          context.read<CheckoutBloc>().add(SetPaidAmountEvent(amount));
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Notes Field
                    AppTextField(
                      controller: _notesController,
                      label: StringsManager.checkoutNotes.lang,
                      hint: StringsManager.checkoutNotesHint.lang,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Receipt Attachment Field
                    ReceiptAttachmentField(
                      receiptPath: _receiptPath,
                      onChanged: (path) => setState(() => _receiptPath = path),
                    ),
                    const SizedBox(height: 30),

                    // Confirm Button
                    AppButton(
                      text: StringsManager.checkoutConfirm.lang,
                      icon: AppIcons.check,
                      onPressed: () {
                        context.read<CheckoutBloc>().add(SubmitCheckoutEvent(
                              items: cartState.items,
                              totalAmount: cartState.totalPrice,
                              notes: _notesController.text,
                              receiptPath: _receiptPath,
                            ));
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

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required String title,
    required PaymentMethod method,
    required dynamic icon,
    required bool selected,
    bool isDebt = false,
  }) {
    final theme = Theme.of(context);
    final activeColor = isDebt ? theme.colorScheme.secondary : theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<CheckoutBloc>().add(SetPaymentMethodEvent(method));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? activeColor.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? activeColor : theme.colorScheme.outlineVariant,
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              AppIcon(icon, color: selected ? activeColor : theme.colorScheme.onSurfaceVariant, size: 22),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? activeColor : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
