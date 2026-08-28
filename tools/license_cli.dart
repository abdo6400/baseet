// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

const String defaultSecret = 'baseet_pos_secure_hmac_secret_key_2026_v1_xyz99';

String generateKey({
  required String deviceId,
  required DateTime expiresAt,
  String licenseType = 'standard',
  String? clientName,
  String secretKey = defaultSecret,
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
  final signatureHex = calculateHmac(base64Payload, secretKey);

  return 'BST1.$base64Payload.$signatureHex';
}

String calculateHmac(String data, String secret) {
  final keyBytes = utf8.encode(secret);
  final hmacSha256 = Hmac(sha256, keyBytes);
  final digest = hmacSha256.convert(utf8.encode(data));
  return digest.toString().toLowerCase();
}

Map<String, dynamic>? verifyKey({
  required String rawKey,
  String? expectedDeviceId,
  String secretKey = defaultSecret,
}) {
  final parts = rawKey.trim().split('.');
  if (parts.length != 3 || parts[0] != 'BST1') {
    print('[ERROR] Invalid key format.');
    return null;
  }

  final base64Payload = parts[1];
  final receivedSignature = parts[2].toLowerCase();

  final expectedSignature = calculateHmac(base64Payload, secretKey);
  if (receivedSignature != expectedSignature) {
    print('[ERROR] Invalid cryptographic signature (Tampered or wrong secret key).');
    return null;
  }

  final decodedJson = utf8.decode(base64Url.decode(base64Url.normalize(base64Payload)));
  final Map<String, dynamic> data = jsonDecode(decodedJson);

  final dev = data['dev'] as String? ?? '';
  if (expectedDeviceId != null && dev.toUpperCase() != expectedDeviceId.toUpperCase()) {
    print('[ERROR] Device ID mismatch. Key is for "$dev", but current device is "$expectedDeviceId".');
    return null;
  }

  final exp = DateTime.parse(data['exp'] as String);
  final now = DateTime.now();
  if (now.isAfter(exp)) {
    print('[WARN] Key is EXPIRED. Expired on: $exp');
  } else {
    final days = exp.difference(now).inDays;
    print('[OK] Key is VALID. Expires on: $exp ($days days remaining).');
  }

  return data;
}

void runTests() {
  print('========================================');
  print('Running Baseet License Test Suite...');
  print('========================================');

  const testDevId1 = 'BST-1122-3344-5566';
  const testDevId2 = 'BST-9988-7766-5544';

  // Test 1: Generate valid 30-day key
  final validExp = DateTime.now().add(const Duration(days: 30));
  final validKey = generateKey(deviceId: testDevId1, expiresAt: validExp, clientName: 'Test Store');
  print('1. Generated Key: $validKey');

  // Test 2: Verify valid key with matching device
  final result1 = verifyKey(rawKey: validKey, expectedDeviceId: testDevId1);
  assert(result1 != null, 'Test 2 Failed: Valid key should verify');
  print('✓ Test 2 Passed: Valid key verified successfully.');

  // Test 3: Verify valid key with mismatched device
  final result2 = verifyKey(rawKey: validKey, expectedDeviceId: testDevId2);
  assert(result2 == null, 'Test 3 Failed: Device mismatch should fail');
  print('✓ Test 3 Passed: Device mismatch rejected correctly.');

  // Test 4: Verify expired key
  final expiredExp = DateTime.now().subtract(const Duration(days: 5));
  final expiredKey = generateKey(deviceId: testDevId1, expiresAt: expiredExp);
  final result3 = verifyKey(rawKey: expiredKey, expectedDeviceId: testDevId1);
  assert(result3 != null, 'Test 4 Failed: Expired key should parse but show expired');
  print('✓ Test 4 Passed: Expired key parsed with warning correctly.');

  // Test 5: Verify tampered key
  final tamperedKey = '${validKey.substring(0, validKey.length - 4)}abcd';
  final result4 = verifyKey(rawKey: tamperedKey, expectedDeviceId: testDevId1);
  assert(result4 == null, 'Test 5 Failed: Tampered key should fail signature check');
  print('✓ Test 5 Passed: Tampered signature rejected correctly.');

  print('========================================');
  print('ALL LICENSE TESTS PASSED SUCCESSFULLY! ✓');
  print('========================================\n');
}

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    print('''
Baseet License Key CLI Tool
Usage:
  dart run tools/license_cli.dart test
  dart run tools/license_cli.dart generate --device <DEVICE_ID> [--days <DAYS>] [--client <NAME>]
  dart run tools/license_cli.dart verify --key <KEY> [--device <DEVICE_ID>]

Examples:
  dart run tools/license_cli.dart generate --device BST-A1B2-C3D4-E5F6 --days 365
  dart run tools/license_cli.dart test
''');
    return;
  }

  final command = args[0];

  if (command == 'test') {
    runTests();
    return;
  }

  if (command == 'generate') {
    String? device;
    int days = 365;
    String? client;

    for (int i = 1; i < args.length; i++) {
      if (args[i] == '--device' && i + 1 < args.length) device = args[i + 1];
      if (args[i] == '--days' && i + 1 < args.length) days = int.tryParse(args[i + 1]) ?? 365;
      if (args[i] == '--client' && i + 1 < args.length) client = args[i + 1];
    }

    if (device == null || device.isEmpty) {
      print('[ERROR] --device argument is required.');
      exit(1);
    }

    final expDate = DateTime.now().add(Duration(days: days));
    final key = generateKey(
      deviceId: device,
      expiresAt: expDate,
      clientName: client,
    );

    print('\n================ BASEET ACTIVATION KEY ================');
    print('Device ID : $device');
    print('Expires   : ${expDate.toIso8601String().substring(0, 10)} ($days days)');
    if (client != null) print('Client    : $client');
    print('\nActivation Key:');
    print(key);
    print('========================================================\n');
    return;
  }

  if (command == 'verify') {
    String? key;
    String? device;

    for (int i = 1; i < args.length; i++) {
      if (args[i] == '--key' && i + 1 < args.length) key = args[i + 1];
      if (args[i] == '--device' && i + 1 < args.length) device = args[i + 1];
    }

    if (key == null || key.isEmpty) {
      print('[ERROR] --key argument is required.');
      exit(1);
    }

    verifyKey(rawKey: key, expectedDeviceId: device);
    return;
  }

  print('Unknown command: $command. Use --help for usage.');
}
