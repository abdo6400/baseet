import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/dialog_extension.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import '../blocs/catalog/pos_catalog_bloc.dart';
import '../blocs/catalog/pos_catalog_event.dart';
import '../blocs/receipts/pos_receipts_bloc.dart';
import '../blocs/receipts/pos_receipts_event.dart';
import '../../domain/entities/order_entity.dart';
import '../utils/pos_pdf_helper.dart';
import 'edit_receipt_dialog.dart';

class ReceiptCard extends StatelessWidget {
  final OrderEntity order;

  const ReceiptCard({super.key, required this.order});

  Color _getPaymentColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppPrimitiveTokens.emerald700;
      case PaymentMethod.debt:
        return AppPrimitiveTokens.red700;
      case PaymentMethod.card:
        return const Color(0xFF1D4ED8);
    }
  }

  String _getPaymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return StringsManager.checkoutCash.lang;
      case PaymentMethod.debt:
        return StringsManager.checkoutDebt.lang;
      case PaymentMethod.card:
        return StringsManager.checkoutCard.lang;
    }
  }

  void _onDelete(BuildContext context) async {
    final confirmed = await context.showConfirmDialog(
      title: StringsManager.receiptsDelete.lang,
      message: StringsManager.receiptsDeleteConfirm.lang,
      confirmText: StringsManager.commonDelete.lang,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<PosReceiptsBloc>().add(DeleteReceiptEvent(order.id));
      context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
      context.read<InventoryListBloc>().add(const LoadInventoryEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringsManager.receiptsDeleteSuccess.lang),
          backgroundColor: AppPrimitiveTokens.red700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onPrintThermal() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => PosPdfHelper.generateThermalReceiptPdf(
        orderId: order.invoiceNumber,
        items: order.items,
        totalPrice: order.totalAmount,
        paidAmount: order.paidAmount,
        changeAmount: order.remainingAmount,
        customerName: order.customerName ?? StringsManager.receiptDefaultCustomer.lang,
        paymentMethod: _getPaymentLabel(order.paymentMethod),
        timestamp: order.createdAt,
      ),
    );
  }

  void _onPrintA4() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => PosPdfHelper.generateTaxInvoicePdf(
        orderId: order.invoiceNumber,
        items: order.items,
        totalPrice: order.totalAmount,
        paidAmount: order.paidAmount,
        changeAmount: order.remainingAmount,
        customerName: order.customerName ?? StringsManager.receiptDefaultCustomer.lang,
        paymentMethod: _getPaymentLabel(order.paymentMethod),
        timestamp: order.createdAt,
      ),
    );
  }

  void _onShare() async {
    await PosPdfHelper.shareReceiptPdf(
      orderId: order.invoiceNumber,
      items: order.items,
      totalPrice: order.totalAmount,
      paidAmount: order.paidAmount,
      changeAmount: order.remainingAmount,
      customerName: order.customerName ?? StringsManager.receiptDefaultCustomer.lang,
      paymentMethod: _getPaymentLabel(order.paymentMethod),
      timestamp: order.createdAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentColor = _getPaymentColor(order.paymentMethod);
    final paymentLabel = _getPaymentLabel(order.paymentMethod);
    final customer = order.customerName?.trim().isNotEmpty == true
        ? order.customerName!
        : StringsManager.receiptDefaultCustomer.lang;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Invoice No + Date + Total
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.safeDp(44),
                  height: context.safeDp(44),
                  decoration: BoxDecoration(
                    color: paymentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: AppIcon(
                      AppIcons.receipt,
                      color: paymentColor,
                      size: context.safeDp(22),
                    ),
                  ),
                ),
                10.hSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${order.invoiceNumber}',
                            style: context.label(
                              15,
                              weight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${order.totalAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                            style: context.label(
                              16,
                              weight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      3.vSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            customer,
                            style: context.label(
                              12,
                              weight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')} - ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                            style: context.label(
                              11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Payment badge & Items summary row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: paymentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: paymentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    paymentLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: paymentColor,
                    ),
                  ),
                ),
                8.hSpace,
                Text(
                  '${order.items.length} ${StringsManager.posItemsCount.lang}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  8.hSpace,
                  Expanded(
                    child: Text(
                      '• ${order.notes}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Items preview chips
          if (order.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: order.items.take(4).map((i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${i.product.name} (x${i.quantity})',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          8.vSpace,
          const Divider(height: 1),

          // Action Toolbar: Thermal, A4, Share, Edit, Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thermal Receipt
                IconButton(
                  tooltip: StringsManager.receiptPrintThermal.lang,
                  icon: AppIcon(AppIcons.printer, size: 18, color: theme.colorScheme.primary),
                  onPressed: _onPrintThermal,
                ),
                // A4 Invoice
                IconButton(
                  tooltip: StringsManager.receiptPrintA4.lang,
                  icon: AppIcon(AppIcons.pdf, size: 18, color: theme.colorScheme.primary),
                  onPressed: _onPrintA4,
                ),
                // Share PDF
                IconButton(
                  tooltip: StringsManager.receiptsShare.lang,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: _onShare,
                ),
                // Edit
                IconButton(
                  tooltip: StringsManager.receiptsEdit.lang,
                  icon: AppIcon(AppIcons.edit, size: 18, color: theme.colorScheme.primary),
                  onPressed: () => EditReceiptDialog.show(context, order),
                ),
                // Delete
                IconButton(
                  tooltip: StringsManager.receiptsDelete.lang,
                  icon: AppIcon(AppIcons.delete, size: 18, color: AppPrimitiveTokens.red700),
                  onPressed: () => _onDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
