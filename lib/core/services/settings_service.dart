import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsService(this._prefs) {
    _cachedHasSeenShowcase = _prefs.getBool(_keyHasSeenShowcase) ?? false;
  }

  static const String _keyStoreName = 'settings_store_name';
  static const String _keyCashierName = 'settings_cashier_name';
  static const String _keyStorePhone = 'settings_store_phone';
  static const String _keyStoreAddress = 'settings_store_address';
  static const String _keyPrinterType = 'settings_printer_type';
  static const String _keyPrinterIp = 'settings_printer_ip';
  static const String _keyPaperSize = 'settings_paper_size';
  static const String _keyAutoPrint = 'settings_auto_print';
  static const String _keyHasSeenShowcase = 'settings_has_seen_showcase';

  // Receipt Customization Keys
  static const String _keyReceiptHeaderTitle = 'settings_receipt_header_title';
  static const String _keyReceiptTaxNumber = 'settings_receipt_tax_number';
  static const String _keyReceiptFooterNote = 'settings_receipt_footer_note';
  static const String _keyReceiptShowLogo = 'settings_receipt_show_logo';
  static const String _keyReceiptShowPhone = 'settings_receipt_show_phone';
  static const String _keyReceiptShowAddress = 'settings_receipt_show_address';
  static const String _keyReceiptShowTax = 'settings_receipt_show_tax';
  static const String _keyReceiptLogoPath = 'settings_receipt_logo_path';

  // Backup Keys
  static const String _keyBackupDirectory = 'settings_backup_directory';
  static const String _keyAutoBackup = 'settings_auto_backup';
  static const String _keyLastBackupDate = 'settings_last_backup_date';

  // In-memory cache for synchronous instant checks
  late bool _cachedHasSeenShowcase;

  // Store Profile Getters
  String get storeName => _prefs.getString(_keyStoreName) ?? 'بسيط';
  String get cashierName => _prefs.getString(_keyCashierName) ?? 'الكاشير';
  String get storePhone => _prefs.getString(_keyStorePhone) ?? '';
  String get storeAddress => _prefs.getString(_keyStoreAddress) ?? '';

  // Printer Getters
  String get printerType => _prefs.getString(_keyPrinterType) ?? 'bluetooth';
  String get printerIp => _prefs.getString(_keyPrinterIp) ?? '192.168.1.100';
  String get paperSize => _prefs.getString(_keyPaperSize) ?? '80mm';
  bool get autoPrintReceipt => _prefs.getBool(_keyAutoPrint) ?? true;

  // Showcase Getters
  bool get hasSeenShowcase => _cachedHasSeenShowcase;

  // Receipt Customization Getters
  String get receiptHeaderTitle => _prefs.getString(_keyReceiptHeaderTitle) ?? storeName;
  String get receiptTaxNumber => _prefs.getString(_keyReceiptTaxNumber) ?? '';
  String get receiptFooterNote =>
      _prefs.getString(_keyReceiptFooterNote) ??
      'شكراً لزيارتكم • البضاعة المباعة ترد وتستبدل خلال 14 يوماً وفق الشروط والأحكام';
  bool get receiptShowLogo => _prefs.getBool(_keyReceiptShowLogo) ?? true;
  bool get receiptShowPhone => _prefs.getBool(_keyReceiptShowPhone) ?? true;
  bool get receiptShowAddress => _prefs.getBool(_keyReceiptShowAddress) ?? true;
  bool get receiptShowTax => _prefs.getBool(_keyReceiptShowTax) ?? true;
  bool get showLogoOnReceipt => receiptShowLogo;
  bool get showStorePhone => receiptShowPhone;
  bool get showStoreAddress => receiptShowAddress;
  bool get showTaxNumber => receiptShowTax;
  String? get receiptLogoPath => _prefs.getString(_keyReceiptLogoPath);

  // Backup Getters
  String get backupDirectoryPath => _prefs.getString(_keyBackupDirectory) ?? '';
  bool get autoBackupEnabled => _prefs.getBool(_keyAutoBackup) ?? true;
  String get lastBackupDate => _prefs.getString(_keyLastBackupDate) ?? '';

  // Store Profile Setters
  Future<void> updateStoreProfile({
    required String name,
    required String phone,
    String? address,
    String? cashier,
  }) async {
    await _prefs.setString(_keyStoreName, name.trim());
    await _prefs.setString(_keyStorePhone, phone.trim());
    if (address != null) {
      await _prefs.setString(_keyStoreAddress, address.trim());
    }
    if (cashier != null && cashier.trim().isNotEmpty) {
      await _prefs.setString(_keyCashierName, cashier.trim());
    }
    notifyListeners();
  }

  // Printer Setters
  Future<void> updatePrinterSettings({
    required String type,
    required String ip,
    required String size,
    required bool autoPrint,
  }) async {
    await _prefs.setString(_keyPrinterType, type);
    await _prefs.setString(_keyPrinterIp, ip);
    await _prefs.setString(_keyPaperSize, size);
    await _prefs.setBool(_keyAutoPrint, autoPrint);
    notifyListeners();
  }

  // Showcase Setters
  Future<void> setHasSeenShowcase(bool value) async {
    _cachedHasSeenShowcase = value;
    await _prefs.setBool(_keyHasSeenShowcase, value);
    notifyListeners();
  }

  // Receipt Customization Setters
  Future<void> updateReceiptSettings({
    required String headerTitle,
    required String taxNumber,
    required String footerNote,
    required bool showLogo,
    required bool showPhone,
    required bool showAddress,
    required bool showTax,
    String? logoPath,
  }) async {
    await _prefs.setString(_keyReceiptHeaderTitle, headerTitle.trim());
    await _prefs.setString(_keyReceiptTaxNumber, taxNumber.trim());
    await _prefs.setString(_keyReceiptFooterNote, footerNote.trim());
    await _prefs.setBool(_keyReceiptShowLogo, showLogo);
    await _prefs.setBool(_keyReceiptShowPhone, showPhone);
    await _prefs.setBool(_keyReceiptShowAddress, showAddress);
    await _prefs.setBool(_keyReceiptShowTax, showTax);
    if (logoPath != null) {
      await _prefs.setString(_keyReceiptLogoPath, logoPath);
    }
    notifyListeners();
  }

  Future<void> setReceiptHeaderTitle(String v) async {
    await _prefs.setString(_keyReceiptHeaderTitle, v.trim());
    notifyListeners();
  }

  Future<void> setReceiptTaxNumber(String v) async {
    await _prefs.setString(_keyReceiptTaxNumber, v.trim());
    notifyListeners();
  }

  Future<void> setReceiptFooterNote(String v) async {
    await _prefs.setString(_keyReceiptFooterNote, v.trim());
    notifyListeners();
  }

  Future<void> setShowLogoOnReceipt(bool v) async {
    await _prefs.setBool(_keyReceiptShowLogo, v);
    notifyListeners();
  }

  Future<void> setShowStorePhone(bool v) async {
    await _prefs.setBool(_keyReceiptShowPhone, v);
    notifyListeners();
  }

  Future<void> setShowStoreAddress(bool v) async {
    await _prefs.setBool(_keyReceiptShowAddress, v);
    notifyListeners();
  }

  Future<void> setShowTaxNumber(bool v) async {
    await _prefs.setBool(_keyReceiptShowTax, v);
    notifyListeners();
  }

  // Backup Setters
  Future<void> setBackupDirectoryPath(String v) async {
    await _prefs.setString(_keyBackupDirectory, v.trim());
    notifyListeners();
  }

  Future<void> setAutoBackupEnabled(bool v) async {
    await _prefs.setBool(_keyAutoBackup, v);
    notifyListeners();
  }

  Future<void> setLastBackupDate(String v) async {
    await _prefs.setString(_keyLastBackupDate, v);
    notifyListeners();
  }

  Future<void> updateBackupSettings({
    required String? directoryPath,
    required bool autoBackup,
    String? lastBackup,
  }) async {
    if (directoryPath != null) {
      await _prefs.setString(_keyBackupDirectory, directoryPath);
    }
    await _prefs.setBool(_keyAutoBackup, autoBackup);
    if (lastBackup != null) {
      await _prefs.setString(_keyLastBackupDate, lastBackup);
    }
    notifyListeners();
  }

  Future<void> recordBackupCompleted() async {
    final nowStr = DateTime.now().toIso8601String();
    await _prefs.setString(_keyLastBackupDate, nowStr);
    notifyListeners();
  }
}
