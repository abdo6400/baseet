import 'package:flutter/services.dart';
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
}
