import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_pdf_helper.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/cart_item_entity.dart';

class PosPdfHelper {
  /// Generate 80mm Thermal Receipt
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

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return AppPdfHelper.wrapDirectionality(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('${StringsManager.appName.lang} - BASEET', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
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

                // Items table
                pw.TableHelper.fromTextArray(
                  headers: [StringsManager.addProductName.lang, StringsManager.inventoryStockQuantityLabel.lang, StringsManager.inventorySellPrice.lang, StringsManager.posTotal.lang],
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
                pw.SizedBox(height: AppSpacing.md),
                pw.Text(StringsManager.receiptThankYou.lang, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${StringsManager.appName.lang} - BASEET POS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                        pw.Text(StringsManager.receiptTaxInvoice.lang, style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
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

                // Sold Items Table
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(StringsManager.receiptSoldItems.lang, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: AppSpacing.sm),
                pw.TableHelper.fromTextArray(
                  headers: ['#', StringsManager.addProductName.lang, StringsManager.addProductBarcode.lang, StringsManager.inventorySellPrice.lang, StringsManager.inventoryStockQuantityLabel.lang, StringsManager.posTotal.lang],
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
                    pw.Container(
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
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${StringsManager.receiptReceiverSignature.lang}: ..........................', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('${StringsManager.receiptCashierSignature.lang}: ..........................', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(StringsManager.receiptElectronicNote.lang, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}

