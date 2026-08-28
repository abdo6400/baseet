import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static const String _keyStoreName = 'settings_store_name';
  static const String _keyCashierName = 'settings_cashier_name';
  static const String _keyStorePhone = 'settings_store_phone';
  static const String _keyStoreAddress = 'settings_store_address';
  static const String _keyPrinterType = 'settings_printer_type';
  static const String _keyPrinterIp = 'settings_printer_ip';
  static const String _keyPaperSize = 'settings_paper_size';
  static const String _keyAutoPrint = 'settings_auto_print';
  static const String _keyHasSeenShowcase = 'settings_has_seen_showcase';

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
  bool get hasSeenShowcase => _prefs.getBool(_keyHasSeenShowcase) ?? false;

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
    await _prefs.setBool(_keyHasSeenShowcase, value);
    notifyListeners();
  }
}
