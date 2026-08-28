import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_pdf_helper.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_invoice_entity.dart';

class SupplierPdfHelper {
  /// Generate Purchase Invoice PDF
  static Future<Uint8List> generateInvoicePdf({
    required SupplierInvoiceEntity invoice,
    required SupplierEntity supplier,
  }) async {
    final pdf = await AppPdfHelper.createDocument();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('${StringsManager.pdfSupplierInvoiceTitle.lang} - ${StringsManager.appName.lang}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.Text('BASEET POS - PURCHASE INVOICE', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(thickness: 1.5, color: PdfColors.teal900),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptInvoiceNo.lang}: #${invoice.id}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${StringsManager.receiptDate.lang}: ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.suppliersName.lang}: ${invoice.supplierName} (${supplier.companyName})'),
                    pw.Text('${StringsManager.suppliersPhone.lang}: ${supplier.phone}'),
                  ],
                ),
                pw.SizedBox(height: AppSpacing.md),

                // Itemized table of purchased goods (RTL column layout)
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(StringsManager.suppliersPurchasedGoods.lang, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: AppSpacing.sm),
                AppPdfHelper.fromRtlTextArray(
                  headers: [
                    '#',
                    StringsManager.suppliersItemName.lang,
                    StringsManager.suppliersItemQuantity.lang,
                    StringsManager.inventoryBuyPrice.lang,
                    StringsManager.posTotal.lang,
                  ],
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.center,
                  data: invoice.items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return [
                      '$idx',
                      item.productName,
                      '${item.quantity}',
                      '${item.unitPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    ];
                  }).toList(),
                ),

                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(),

                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.posTotal.lang}:', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${invoice.totalAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptPaid.lang}:'),
                    pw.Text('${invoice.paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.suppliersRemainingDebt.lang}:', style: pw.TextStyle(color: PdfColors.red800, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${invoice.remainingAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: pw.TextStyle(color: PdfColors.red800, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                  pw.SizedBox(height: AppSpacing.sm),
                  pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('${StringsManager.checkoutNotes.lang}: ${invoice.notes}')),
                ],
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate Supplier Statement PDF
  static Future<Uint8List> generateStatementPdf({
    required SupplierEntity supplier,
    required List<SupplierInvoiceEntity> invoices,
  }) async {
    final pdf = await AppPdfHelper.createDocument();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('${StringsManager.pdfSupplierStatementTitle.lang} - ${StringsManager.appName.lang}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.Text('BASEET POS - SUPPLIER STATEMENT', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(thickness: 1.5, color: PdfColors.teal900),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.suppliersName.lang}: ${supplier.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${StringsManager.suppliersCompanyName.lang}: ${supplier.companyName}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.suppliersPhone.lang}: ${supplier.phone}'),
                    pw.Text('${StringsManager.suppliersOwed.lang}: ${supplier.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: AppSpacing.md),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('${StringsManager.suppliersInvoicesHistory.lang} (${invoices.length})', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: AppSpacing.sm),

                // Invoices summary table (RTL column layout)
                AppPdfHelper.fromRtlTextArray(
                  headers: [
                    StringsManager.receiptInvoiceNo.lang,
                    StringsManager.receiptDate.lang,
                    StringsManager.suppliersPurchasedGoods.lang,
                    StringsManager.posTotal.lang,
                    StringsManager.receiptPaid.lang,
                    StringsManager.receiptChange.lang,
                  ],
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  cellAlignment: pw.Alignment.center,
                  data: invoices.map((inv) {
                    final itemsSummary = inv.items.map((i) => '${i.productName} (x${i.quantity})').join('\n');
                    return [
                      '#${inv.id}',
                      '${inv.date.day}/${inv.date.month}/${inv.date.year}',
                      itemsSummary,
                      '${inv.totalAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${inv.paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${inv.remainingAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    '${StringsManager.suppliersTotalOwed.lang}: ${supplier.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
