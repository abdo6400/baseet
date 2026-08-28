import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AppPdfHelper {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Loads and caches the IBM Plex Sans Arabic TTF fonts for PDF generation
  static Future<pw.ThemeData> getArabicPdfTheme() async {
    if (_regularFont == null || _boldFont == null) {
      final regularData = await rootBundle.load('assets/fonts/IBM_Plex_Sans_Arabic/IBMPlexSansArabic-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/IBM_Plex_Sans_Arabic/IBMPlexSansArabic-Bold.ttf');
      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);
    }

    return pw.ThemeData.withFont(
      base: _regularFont!,
      bold: _boldFont!,
    );
  }

  /// Creates a pw.Document pre-configured with the Arabic font theme
  static Future<pw.Document> createDocument() async {
    final theme = await getArabicPdfTheme();
    return pw.Document(theme: theme);
  }

  /// Wraps page content with correct RTL text directionality
  static pw.Widget wrapDirectionality({required pw.Widget child, bool isRtl = true}) {
    return pw.Directionality(
      textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: child,
    );
  }

  /// Creates a PDF Table with proper Right-to-Left (RTL) column ordering for Arabic
  static pw.Widget fromRtlTextArray({
    required List<String> headers,
    required List<List<dynamic>> data,
    bool isRtl = true,
    pw.BoxDecoration? headerDecoration,
    pw.TextStyle? headerStyle,
    pw.TextStyle? cellStyle,
    pw.Alignment cellAlignment = pw.Alignment.center,
    pw.TableBorder? border = const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
    ),
    pw.EdgeInsets cellPadding = const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    Map<int, pw.TableColumnWidth>? columnWidths,
  }) {
    final effectiveHeaders = isRtl ? headers.reversed.toList() : headers;
    final effectiveData = isRtl
        ? data.map((row) => row.reversed.toList()).toList()
        : data;

    Map<int, pw.TableColumnWidth>? effectiveColumnWidths;
    if (columnWidths != null && isRtl) {
      effectiveColumnWidths = {
        for (final entry in columnWidths.entries)
          (headers.length - 1 - entry.key): entry.value,
      };
    } else {
      effectiveColumnWidths = columnWidths;
    }

    return pw.TableHelper.fromTextArray(
      headers: effectiveHeaders,
      data: effectiveData,
      headerDecoration: headerDecoration ?? const pw.BoxDecoration(color: PdfColors.grey200),
      headerStyle: headerStyle ?? pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      cellStyle: cellStyle ?? const pw.TextStyle(fontSize: 9),
      cellAlignment: cellAlignment,
      border: border,
      cellPadding: cellPadding,
      columnWidths: effectiveColumnWidths,
    );
  }
}
