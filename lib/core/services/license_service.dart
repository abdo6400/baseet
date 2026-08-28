import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_id_service.dart';

enum LicenseStatus {
  unactivated,
  active,
  expired,
  invalid,
}

enum ActivationError {
  none,
  invalidFormat,
  invalidSignature,
  deviceMismatch,
  alreadyExpired,
  clockTampered,
  unknown,
}

class LicenseInfo {
  final String deviceId;
  final DateTime expiresAt;
  final String licenseType;
  final DateTime issuedAt;
  final String? clientName;
  final String rawKey;

  const LicenseInfo({
    required this.deviceId,
    required this.expiresAt,
    required this.licenseType,
    required this.issuedAt,
    this.clientName,
    required this.rawKey,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get daysRemaining {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get hoursRemaining {
    final diff = expiresAt.difference(DateTime.now()).inHours;
    return diff < 0 ? 0 : diff;
  }

  Map<String, dynamic> toJson() => {
        'dev': deviceId,
        'exp': expiresAt.toIso8601String(),
        'type': licenseType,
        'iat': issuedAt.millisecondsSinceEpoch,
        if (clientName != null) 'client': clientName,
      };

  factory LicenseInfo.fromJson(Map<String, dynamic> json, String rawKey) {
    return LicenseInfo(
      deviceId: (json['dev'] as String? ?? '').toUpperCase().trim(),
      expiresAt: DateTime.parse(json['exp'] as String),
      licenseType: json['type'] as String? ?? 'standard',
      issuedAt: DateTime.fromMillisecondsSinceEpoch(json['iat'] as int? ?? 0),
      clientName: json['client'] as String?,
      rawKey: rawKey,
    );
  }
}

class ActivationResult {
  final bool isSuccess;
  final ActivationError error;
  final LicenseInfo? licenseInfo;
  final String? errorMessage;

  const ActivationResult({
    required this.isSuccess,
    this.error = ActivationError.none,
    this.licenseInfo,
    this.errorMessage,
  });

  factory ActivationResult.success(LicenseInfo info) => ActivationResult(
        isSuccess: true,
        error: ActivationError.none,
        licenseInfo: info,
      );

  factory ActivationResult.failed(ActivationError error, [String? message]) =>
      ActivationResult(
        isSuccess: false,
        error: error,
        errorMessage: message,
      );
}

class LicenseService extends ChangeNotifier {
  final DeviceIdService _deviceIdService;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String secretKey =
      'baseet_pos_secure_hmac_secret_key_2026_v1_xyz99';

  static const String _keyStoredLicense = 'bst_stored_license_key';
  static const String _keyLastVerifiedTimestamp = 'bst_license_last_timestamp';

  LicenseInfo? _cachedLicenseInfo;
  LicenseStatus _cachedStatus = LicenseStatus.unactivated;

  LicenseService(
    this._deviceIdService,
    this._prefs, [
    FlutterSecureStorage? secureStorage,
  ]) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  LicenseStatus get currentStatus => _cachedStatus;
  LicenseInfo? get currentLicense => _cachedLicenseInfo;

  /// Checks the current license status from storage
  Future<LicenseStatus> checkLicense() async {
    final rawKey = await _getStoredKey();
    if (rawKey == null || rawKey.trim().isEmpty) {
      _cachedStatus = LicenseStatus.unactivated;
      _cachedLicenseInfo = null;
      notifyListeners();
      return _cachedStatus;
    }

    final currentDeviceId = await _deviceIdService.getDeviceId();
    final result = _verifyKeySync(rawKey, currentDeviceId);

    if (result.isSuccess && result.licenseInfo != null) {
      final info = result.licenseInfo!;
      final now = DateTime.now();

      // Anti-clock rollback check
      final lastTimestamp = _prefs.getInt(_keyLastVerifiedTimestamp) ?? 0;
      if (now.millisecondsSinceEpoch < lastTimestamp - 60000) {
        // Clock has been turned back more than 1 minute
        _cachedStatus = LicenseStatus.invalid;
        _cachedLicenseInfo = info;
        notifyListeners();
        return _cachedStatus;
      }

      // Update last verified timestamp
      await _prefs.setInt(
          _keyLastVerifiedTimestamp, now.millisecondsSinceEpoch);

      if (now.isAfter(info.expiresAt)) {
        _cachedStatus = LicenseStatus.expired;
      } else {
        _cachedStatus = LicenseStatus.active;
      }
      _cachedLicenseInfo = info;
    } else {
      if (result.error == ActivationError.alreadyExpired) {
        _cachedStatus = LicenseStatus.expired;
        _cachedLicenseInfo = result.licenseInfo;
      } else {
        _cachedStatus = LicenseStatus.invalid;
        _cachedLicenseInfo = null;
      }
    }

    notifyListeners();
    return _cachedStatus;
  }

  /// Attempts to activate with a new raw key entered by the user
  Future<ActivationResult> activateKey(String inputKey) async {
    final cleanedKey = inputKey.trim().replaceAll('\r', '').replaceAll('\n', '');
    if (cleanedKey.isEmpty) {
      return ActivationResult.failed(ActivationError.invalidFormat);
    }

    final currentDeviceId = await _deviceIdService.getDeviceId();
    final result = _verifyKeySync(cleanedKey, currentDeviceId);

    if (result.isSuccess && result.licenseInfo != null) {
      // Save valid key
      await _saveStoredKey(cleanedKey);
      await _prefs.setInt(
          _keyLastVerifiedTimestamp, DateTime.now().millisecondsSinceEpoch);

      _cachedLicenseInfo = result.licenseInfo;
      _cachedStatus = LicenseStatus.active;
      notifyListeners();
      return result;
    }

    return result;
  }

  /// Synchronously verifies cryptographic signature and constraints
  ActivationResult _verifyKeySync(String rawKey, String currentDeviceId) {
    try {
      // Expected format: BST1.<base64Payload>.<signatureHex>
      final normalized = rawKey.trim();
      final parts = normalized.split('.');

      if (parts.length != 3 || parts[0] != 'BST1') {
        return ActivationResult.failed(ActivationError.invalidFormat);
      }

      final base64Payload = parts[1];
      final receivedSignatureHex = parts[2].toLowerCase();

      // Verify HMAC-SHA256 signature
      final expectedSignatureHex = _calculateHmac(base64Payload);
      if (receivedSignatureHex != expectedSignatureHex) {
        return ActivationResult.failed(ActivationError.invalidSignature);
      }

      // Decode JSON payload
      final decodedJsonStr = utf8.decode(base64Url.decode(base64Url.normalize(base64Payload)));
      final Map<String, dynamic> data = jsonDecode(decodedJsonStr);

      final licenseInfo = LicenseInfo.fromJson(data, rawKey);

      // Verify Device ID
      if (licenseInfo.deviceId.toUpperCase() != currentDeviceId.toUpperCase()) {
        return ActivationResult.failed(
          ActivationError.deviceMismatch,
          'Key belongs to device: ${licenseInfo.deviceId}',
        );
      }

      // Check Expiration
      if (DateTime.now().isAfter(licenseInfo.expiresAt)) {
        return ActivationResult(
          isSuccess: false,
          error: ActivationError.alreadyExpired,
          licenseInfo: licenseInfo,
        );
      }

      return ActivationResult.success(licenseInfo);
    } catch (e) {
      debugPrint('License verification error: $e');
      return ActivationResult.failed(ActivationError.invalidFormat, e.toString());
    }
  }

  /// Static helper to generate a key (used by tools and tests)
  static String generateKey({
    required String deviceId,
    required DateTime expiresAt,
    String licenseType = 'standard',
    String? clientName,
    String customSecret = secretKey,
  }) {
    final payloadMap = {
      'v': 1,
      'dev': deviceId.toUpperCase().trim(),
      'exp': expiresAt.toUtc().toIso8601String(),
      'type': licenseType,
      'iat': DateTime.now().millisecondsSinceEpoch,
      if (clientName != null && clientName.isNotEmpty) 'client': clientName,
    };

    final jsonStr = jsonEncode(payloadMap);
    final base64Payload = base64Url.encode(utf8.encode(jsonStr)).replaceAll('=', '');
    final signatureHex = _calculateHmacWithSecret(base64Payload, customSecret);

    return 'BST1.$base64Payload.$signatureHex';
  }

  static String _calculateHmac(String data) {
    return _calculateHmacWithSecret(data, secretKey);
  }

  static String _calculateHmacWithSecret(String data, String secret) {
    final keyBytes = utf8.encode(secret);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(utf8.encode(data));
    return digest.toString().toLowerCase();
  }

  Future<String?> _getStoredKey() async {
    try {
      final secureKey = await _secureStorage.read(key: _keyStoredLicense);
      if (secureKey != null && secureKey.isNotEmpty) {
        return secureKey;
      }
    } catch (e) {
      debugPrint('Error reading secure storage: $e');
    }
    return _prefs.getString(_keyStoredLicense);
  }

  Future<void> _saveStoredKey(String key) async {
    try {
      await _secureStorage.write(key: _keyStoredLicense, value: key);
    } catch (e) {
      debugPrint('Error writing to secure storage: $e');
    }
    await _prefs.setString(_keyStoredLicense, key);
  }

  /// Clears stored license (for testing or reset)
  Future<void> clearLicense() async {
    try {
      await _secureStorage.delete(key: _keyStoredLicense);
    } catch (e) {
      debugPrint('Error clearing secure storage: $e');
    }
    await _prefs.remove(_keyStoredLicense);
    await _prefs.remove(_keyLastVerifiedTimestamp);
    _cachedLicenseInfo = null;
    _cachedStatus = LicenseStatus.unactivated;
    notifyListeners();
  }
}
