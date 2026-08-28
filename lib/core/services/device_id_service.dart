import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  final SharedPreferences _prefs;
  final DeviceInfoPlugin _deviceInfoPlugin;

  static const String _keyCachedDeviceId = 'bst_cached_device_id';
  String? _cachedDeviceId;

  DeviceIdService(this._prefs, [DeviceInfoPlugin? plugin])
      : _deviceInfoPlugin = plugin ?? DeviceInfoPlugin();

  /// Returns the formatted unique device identifier, e.g. "BST-A1B2-C3D4-E5F6"
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    final storedId = _prefs.getString(_keyCachedDeviceId);
    if (storedId != null && storedId.trim().isNotEmpty) {
      _cachedDeviceId = storedId.trim().toUpperCase();
      return _cachedDeviceId!;
    }

    final rawHardwareId = await _getRawHardwareId();
    final formattedId = _formatToDeviceId(rawHardwareId);

    await _prefs.setString(_keyCachedDeviceId, formattedId);
    _cachedDeviceId = formattedId;
    return formattedId;
  }

  /// Extracts platform-specific hardware identifier
  Future<String> _getRawHardwareId() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return '${webInfo.vendor}_${webInfo.userAgent}_${webInfo.hardwareConcurrency}';
      }

      if (Platform.isWindows) {
        final win = await _deviceInfoPlugin.windowsInfo;
        return '${win.deviceId}_${win.computerName}_${win.numberOfCores}';
      } else if (Platform.isAndroid) {
        final android = await _deviceInfoPlugin.androidInfo;
        return '${android.id}_${android.fingerprint}_${android.hardware}';
      } else if (Platform.isIOS) {
        final ios = await _deviceInfoPlugin.iosInfo;
        return '${ios.identifierForVendor}_${ios.model}';
      } else if (Platform.isLinux) {
        final linux = await _deviceInfoPlugin.linuxInfo;
        return '${linux.machineId}_${linux.name}';
      } else if (Platform.isMacOS) {
        final mac = await _deviceInfoPlugin.macOsInfo;
        return '${mac.systemGUID}_${mac.computerName}';
      }
    } catch (e) {
      debugPrint('Error getting raw hardware ID: $e');
    }

    // Fallback to random persistent seed
    final fallbackSeed = '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}';
    return fallbackSeed;
  }

  /// Formats raw hardware string into BST-XXXX-XXXX-XXXX
  String _formatToDeviceId(String rawId) {
    final bytes = utf8.encode('baseet_hardware_salt_$rawId');
    final digest = sha256.convert(bytes);
    final hexString = digest.toString().toUpperCase();

    // Take 12 characters: 3 groups of 4 chars
    final part1 = hexString.substring(0, 4);
    final part2 = hexString.substring(4, 8);
    final part3 = hexString.substring(8, 12);

    return 'BST-$part1-$part2-$part3';
  }
}
