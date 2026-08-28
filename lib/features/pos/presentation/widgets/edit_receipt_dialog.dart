import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_event.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import '../blocs/catalog/pos_catalog_bloc.dart';
import '../blocs/catalog/pos_catalog_event.dart';
import '../blocs/receipts/pos_receipts_bloc.dart';
import '../blocs/receipts/pos_receipts_event.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';

class EditReceiptDialog extends StatefulWidget {
  final OrderEntity order;

  const EditReceiptDialog({super.key, required this.order});

  static Future<bool?> show(BuildContext context, OrderEntity order) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditReceiptDialog(order: order),
    );
  }

  @override
  State<EditReceiptDialog> createState() => _EditReceiptDialogState();
}

class _EditReceiptDialogState extends State<EditReceiptDialog> {
  late List<CartItemEntity> _items;
  late PaymentMethod _paymentMethod;
  late TextEditingController _notesController;
  late TextEditingController _paidAmountController;
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  @override
  void initState() {
    super.initState();
    _items = widget.order.items.map((i) => i.copyWith()).toList();
    _paymentMethod = widget.order.paymentMethod;
    _notesController = TextEditingController(text: widget.order.notes ?? '');
    _paidAmountController =
        TextEditingController(text: widget.order.paidAmount.toStringAsFixed(0));
    _selectedCustomerId = widget.order.customerId;
    _selectedCustomerName = widget.order.customerName;

    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  double get _totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get _paidAmount =>
      double.tryParse(_paidAmountController.text.trim()) ?? _totalPrice;

  double get _remainingAmount {
    if (_paymentMethod == PaymentMethod.debt) {
      return (_totalPrice - _paidAmount).clamp(0.0, double.infinity);
    }
    return 0.0;
  }

  void _onItemQtyChanged(int index, int delta) {
    setState(() {
      final item = _items[index];
      final newQty = item.quantity + delta;
      if (newQty > 0) {
        _items[index] = item.copyWith(quantity: newQty);
      } else if (newQty <= 0 && _items.length > 1) {
        _items.removeAt(index);
      }
      if (_paymentMethod != PaymentMethod.debt) {
        _paidAmountController.text = _totalPrice.toStringAsFixed(0);
      }
    });
  }

  void _onSave() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringsManager.posEmptyCart.lang),
          backgroundColor: AppPrimitiveTokens.red700,
        ),
      );
      return;
    }

    if (_paymentMethod == PaymentMethod.debt && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringsManager.checkoutErrorSelectCustomer.lang),
          backgroundColor: AppPrimitiveTokens.red700,
        ),
      );
      return;
    }

    final paid = _paymentMethod == PaymentMethod.debt ? _paidAmount : _totalPrice;
    final remaining = _paymentMethod == PaymentMethod.debt
        ? (_totalPrice - paid).clamp(0.0, double.infinity)
        : 0.0;

    final updatedOrder = widget.order.copyWith(
      items: _items,
      totalAmount: _totalPrice,
      paidAmount: paid,
      remainingAmount: remaining,
      paymentMethod: _paymentMethod,
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName,
      notes: _notesController.text.trim(),
    );

    context.read<PosReceiptsBloc>().add(UpdateReceiptEvent(updatedOrder));
    context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());

    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(StringsManager.receiptsEditSuccess.lang),
        backgroundColor: AppPrimitiveTokens.emerald700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customers = context.watch<CustomersListBloc>().state.customers;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringsManager.receiptsEditTitle.lang,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '#${widget.order.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Sold Items Section
                Text(
                  StringsManager.receiptSoldItems.lang,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                8.vSpace,
                ..._items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              2.vSpace,
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
                        // Qty Controller Buttons
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              color: AppPrimitiveTokens.red700,
                              onPressed: () => _onItemQtyChanged(idx, -1),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.add_circle_outline, size: 20, color: theme.colorScheme.primary),
                              onPressed: () => _onItemQtyChanged(idx, 1),
                            ),
                          ],
                        ),
                        10.hSpace,
                        Text(
                          '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                16.vSpace,

                // Payment Method Selector
                Text(
                  StringsManager.checkoutPaymentMethod.lang,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                8.vSpace,
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(StringsManager.checkoutCash.lang)),
                        selected: _paymentMethod == PaymentMethod.cash,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _paymentMethod = PaymentMethod.cash;
                              _paidAmountController.text = _totalPrice.toStringAsFixed(0);
                            });
                          }
                        },
                      ),
                    ),
                    8.hSpace,
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(StringsManager.checkoutDebt.lang)),
                        selected: _paymentMethod == PaymentMethod.debt,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _paymentMethod = PaymentMethod.debt;
                            });
                          }
                        },
                      ),
                    ),
                    8.hSpace,
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(StringsManager.checkoutCard.lang)),
                        selected: _paymentMethod == PaymentMethod.card,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _paymentMethod = PaymentMethod.card;
                              _paidAmountController.text = _totalPrice.toStringAsFixed(0);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                16.vSpace,

                // Customer Selection (if Debt or optional)
                if (_paymentMethod == PaymentMethod.debt || customers.isNotEmpty) ...[
                  Text(
                    StringsManager.checkoutCustomer.lang,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  8.vSpace,
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCustomerId,
                    decoration: InputDecoration(
                      hintText: StringsManager.checkoutSelectCustomer.lang,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: customers.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text('${c.name} (${c.phone})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomerId = val;
                        final cust = customers.where((c) => c.id == val).firstOrNull;
                        _selectedCustomerName = cust?.name;
                      });
                    },
                  ),
                  16.vSpace,
                ],

                // Paid amount (for Debt)
                if (_paymentMethod == PaymentMethod.debt) ...[
                  Text(
                    StringsManager.checkoutReceivedAmount.lang,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  8.vSpace,
                  TextField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      suffixText: StringsManager.posCurrency.lang,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  8.vSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(StringsManager.checkoutRemainingAmount.lang),
                      Text(
                        '${_remainingAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppPrimitiveTokens.red700),
                      ),
                    ],
                  ),
                  16.vSpace,
                ],

                // Notes
                Text(
                  StringsManager.checkoutNotes.lang,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                8.vSpace,
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: StringsManager.checkoutNotesHint.lang,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ],
            ),
          ),

          // Total Summary & Save Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringsManager.posTotal.lang,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  12.vSpace,
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlinedButton(
                          text: StringsManager.commonCancel.lang,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      12.hSpace,
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: StringsManager.commonSave.lang,
                          icon: AppIcons.check,
                          onPressed: _onSave,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
