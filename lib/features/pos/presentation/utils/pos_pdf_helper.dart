import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_pdf_helper.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/cart_item_entity.dart';

class PosPdfHelper {
  /// Generate 80mm / 58mm Thermal Receipt
  static Future<Uint8List> generateThermalReceiptPdf({
    required String orderId,
    required List<CartItemEntity> items,
    required double totalPrice,
    required double paidAmount,
    required double changeAmount,
    required String customerName,
    required String paymentMethod,
    required DateTime timestamp,
  }) async {
    final doc = await AppPdfHelper.createDocument();
    final settings = sl<SettingsService>();
    final headerTitle = settings.receiptHeaderTitle.isNotEmpty
        ? settings.receiptHeaderTitle
        : '${StringsManager.appName.lang} - BASEET';
    final taxNo = settings.receiptTaxNumber;
    final footerNote = settings.receiptFooterNote.isNotEmpty
        ? settings.receiptFooterNote
        : StringsManager.receiptThankYou.lang;
    final is58mm = settings.paperSize == '58mm';

    Uint8List? logoBytes;
    if (settings.showLogoOnReceipt && settings.receiptLogoPath != null && settings.receiptLogoPath!.isNotEmpty) {
      final file = File(settings.receiptLogoPath!);
      if (file.existsSync()) {
        try {
          logoBytes = file.readAsBytesSync();
        } catch (_) {}
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: is58mm ? PdfPageFormat.roll57 : PdfPageFormat.roll80,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoBytes != null)
                  pw.Container(
                    height: is58mm ? 36 : 48,
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Image(pw.MemoryImage(logoBytes)),
                  ),
                pw.Text(headerTitle, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                if (settings.showTaxNumber && taxNo.isNotEmpty)
                  pw.Text('${StringsManager.receiptTaxNumberLabel.lang}: $taxNo', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.Text(StringsManager.pdfThermalReceiptTitle.lang, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.SizedBox(height: AppSpacing.xs + 2),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptInvoiceNo.lang}: #$orderId', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptCustomer.lang}: $customerName', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${StringsManager.receiptPaymentMethod.lang}: $paymentMethod', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.SizedBox(height: AppSpacing.xs + 2),
                pw.Divider(),

                // Items table (RTL column layout for Arabic)
                AppPdfHelper.fromRtlTextArray(
                  headers: [
                    StringsManager.addProductName.lang,
                    StringsManager.inventoryStockQuantityLabel.lang,
                    StringsManager.inventorySellPrice.lang,
                    StringsManager.posTotal.lang,
                  ],
                  headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  data: items.map((item) {
                    return [
                      item.product.name,
                      '${item.quantity}',
                      '${item.product.sellPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    ];
                  }).toList(),
                ),

                pw.SizedBox(height: AppSpacing.sm),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.posTotal.lang}:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${totalPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptPaid.lang}:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptChange.lang}:', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${changeAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                if (settings.showSignatureOnReceipt) ...[
                  pw.SizedBox(height: AppSpacing.sm),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${StringsManager.receiptReceiverSignature.lang}: .........', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('${StringsManager.receiptCashierSignature.lang}: .........', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
                if (settings.showFooterNoteOnReceipt && footerNote.isNotEmpty) ...[
                  pw.SizedBox(height: AppSpacing.sm),
                  pw.Text(footerNote, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                ],
                if (settings.showStorePhone && settings.storePhone.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text('${StringsManager.storeSettingsPhoneLabel.lang}: ${settings.storePhone}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
                ],
                if (settings.showStoreAddress && settings.storeAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(settings.storeAddress, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
                ],
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Generate Official A4 Tax / Sales Invoice
  static Future<Uint8List> generateTaxInvoicePdf({
    required String orderId,
    required List<CartItemEntity> items,
    required double totalPrice,
    required double paidAmount,
    required double changeAmount,
    required String customerName,
    required String paymentMethod,
    required DateTime timestamp,
  }) async {
    final doc = await AppPdfHelper.createDocument();
    final settings = sl<SettingsService>();
    final headerTitle = settings.receiptHeaderTitle.isNotEmpty
        ? settings.receiptHeaderTitle
        : '${StringsManager.appName.lang} - BASEET POS';
    final taxNo = settings.receiptTaxNumber;
    final footerNote = settings.receiptFooterNote.isNotEmpty
        ? settings.receiptFooterNote
        : StringsManager.receiptElectronicNote.lang;

    Uint8List? logoBytes;
    if (settings.showLogoOnReceipt && settings.receiptLogoPath != null && settings.receiptLogoPath!.isNotEmpty) {
      final file = File(settings.receiptLogoPath!);
      if (file.existsSync()) {
        try {
          logoBytes = file.readAsBytesSync();
        } catch (_) {}
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoBytes != null)
                          pw.Container(
                            height: 48,
                            width: 48,
                            margin: const pw.EdgeInsets.only(left: 12),
                            child: pw.Image(pw.MemoryImage(logoBytes)),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(headerTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                            pw.Text(StringsManager.receiptTaxInvoice.lang, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                            if (settings.showTaxNumber && taxNo.isNotEmpty)
                              pw.Text('${StringsManager.receiptTaxNumberLabel.lang}: $taxNo', style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('${StringsManager.receiptInvoiceNo.lang}: #$orderId', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${StringsManager.receiptDate.lang}: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(thickness: 1.5, color: PdfColors.teal800),

                // Customer & Payment Details Card
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${StringsManager.receiptCustomer.lang}: $customerName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${StringsManager.receiptPaymentMethod.lang}: $paymentMethod', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.SizedBox(height: AppSpacing.md),

                // Sold Items Table (RTL column layout for Arabic)
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(StringsManager.receiptSoldItems.lang, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: AppSpacing.sm),
                AppPdfHelper.fromRtlTextArray(
                  headers: [
                    '#',
                    StringsManager.addProductName.lang,
                    StringsManager.addProductBarcode.lang,
                    StringsManager.inventorySellPrice.lang,
                    StringsManager.inventoryStockQuantityLabel.lang,
                    StringsManager.posTotal.lang,
                  ],
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.center,
                  data: items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return [
                      '$idx',
                      item.product.name,
                      item.product.barcode.isNotEmpty ? item.product.barcode : '-',
                      '${item.product.sellPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                      '${item.quantity}',
                      '${item.subtotal.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                    ];
                  }).toList(),
                ),

                pw.SizedBox(height: AppSpacing.md),
                pw.Divider(),

                // Financial Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.SizedBox(
                      width: 250,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('${StringsManager.posTotal.lang}:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('${totalPrice.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('${StringsManager.receiptPaid.lang}:'),
                              pw.Text('${paidAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}'),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('${StringsManager.receiptChange.lang}:'),
                              pw.Text('${changeAmount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                if (settings.showSignatureOnReceipt) ...[
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${StringsManager.receiptReceiverSignature.lang}: ..........................', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('${StringsManager.receiptCashierSignature.lang}: ..........................', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
                if (settings.showFooterNoteOnReceipt && footerNote.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(footerNote, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600), textAlign: pw.TextAlign.center),
                ],
                if (settings.showStorePhone && settings.storePhone.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text('${StringsManager.storeSettingsPhoneLabel.lang}: ${settings.storePhone}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500), textAlign: pw.TextAlign.center),
                ],
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  /// Share Receipt PDF
  static Future<void> shareReceiptPdf({
    required String orderId,
    required List<CartItemEntity> items,
    required double totalPrice,
    required double paidAmount,
    required double changeAmount,
    required String customerName,
    required String paymentMethod,
    required DateTime timestamp,
  }) async {
    final pdfBytes = await generateTaxInvoicePdf(
      orderId: orderId,
      items: items,
      totalPrice: totalPrice,
      paidAmount: paidAmount,
      changeAmount: changeAmount,
      customerName: customerName,
      paymentMethod: paymentMethod,
      timestamp: timestamp,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'invoice_$orderId.pdf',
    );
  }
}
