import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../utils/pos_pdf_helper.dart';
import '../widgets/receipt_item_tile.dart';
import '../widgets/receipt_financial_summary.dart';

class ReceiptPage extends StatelessWidget {
  final String orderId;
  final List<CartItemEntity> items;
  final double totalPrice;
  final double paidAmount;
  final double changeAmount;
  final String customerName;
  final String paymentMethod;
  final DateTime timestamp;

  const ReceiptPage({
    super.key,
    required this.orderId,
    required this.items,
    required this.totalPrice,
    required this.paidAmount,
    required this.changeAmount,
    this.customerName = 'عميل نقدي',
    required this.paymentMethod,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageWrapper(
      scrollable: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      appBar: PageHeader(
        title: StringsManager.receiptTitle.lang,
        showBackButton: false,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.close, size: 20),
            onPressed: () => context.go('/pos'),
          ),
        ],
      ),
      child: Column(
        children: [
          // Receipt Container Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppPrimitiveTokens.emerald700.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(AppIcons.check, color: AppPrimitiveTokens.emerald700, size: 34),
                  ),
                ),
                12.vSpace,
                Text(
                  StringsManager.receiptSaleSuccess.lang,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                4.vSpace,
                Text(
                  '${StringsManager.receiptInvoiceNo.lang}: #$orderId',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
                ),
                const Divider(height: AppSpacing.lg),

                // Customer & Payment Info
                _buildRow(StringsManager.receiptCustomer.lang, customerName, theme),
                _buildRow(StringsManager.receiptPaymentMethod.lang, paymentMethod, theme),
                _buildRow(StringsManager.receiptDate.lang, '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} - ${timestamp.day}/${timestamp.month}/${timestamp.year}', theme),
                const Divider(height: AppSpacing.lg),

                // Items List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${StringsManager.receiptSoldItems.lang} (${items.length})',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                    ),
                    Text(
                      StringsManager.receiptQtyPrice.lang,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                    ),
                  ],
                ),
                8.vSpace,

                // Items List using ReceiptItemTile
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return ReceiptItemTile(
                      index: index + 1,
                      item: items[index],
                    );
                  },
                ),
                const Divider(height: AppSpacing.lg),

                // Total & Summary using ReceiptFinancialSummary
                ReceiptFinancialSummary(
                  totalPrice: totalPrice,
                  paidAmount: paidAmount,
                  changeAmount: changeAmount,
                ),
              ],
            ),
          ),
          20.vSpace,

          // Action Buttons (80mm Thermal Print + A4 Tax Invoice Print)
          Column(
            children: [
              AppButton(
                text: StringsManager.receiptPrintThermal.lang,
                icon: AppIcons.printer,
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => PosPdfHelper.generateThermalReceiptPdf(
                      orderId: orderId,
                      items: items,
                      totalPrice: totalPrice,
                      paidAmount: paidAmount,
                      changeAmount: changeAmount,
                      customerName: customerName,
                      paymentMethod: paymentMethod,
                      timestamp: timestamp,
                    ),
                  );
                },
              ),
              10.vSpace,
              AppOutlinedButton(
                text: StringsManager.receiptPrintA4.lang,
                icon: AppIcons.pdf,
                borderColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.primary,
                width: double.infinity,
                height: 48,
                borderRadius: AppRadius.lg,
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => PosPdfHelper.generateA4InvoicePdf(
                      orderId: orderId,
                      items: items,
                      totalPrice: totalPrice,
                      paidAmount: paidAmount,
                      changeAmount: changeAmount,
                      customerName: customerName,
                      paymentMethod: paymentMethod,
                      timestamp: timestamp,
                    ),
                  );
                },
              ),
              8.vSpace,
              TextButton.icon(
                onPressed: () => context.go('/pos'),
                icon: AppIcon(AppIcons.cart, size: 18),
                label: Text(
                  StringsManager.receiptNewSale.lang,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
