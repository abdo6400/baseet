import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:baseet/core/error/exceptions.dart';
import '../../domain/entities/backup_snapshot.dart';

class LocalTransfer {
  HttpServer? _server;
  Timer? _expiry;
  final algorithm = AesGcm.with256bits();
  static bool privateHost(String value) {
    final address = InternetAddress.tryParse(value);
    if (address == null || address.type != InternetAddressType.IPv4) {
      return false;
    }
    final b = address.rawAddress;
    return b[0] == 10 ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 && b[1] == 168);
  }

  Future<TransferSession> start(String contents, {String? testHost}) async {
    await stop();
    final interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    final addresses = interfaces
        .expand((i) => i.addresses)
        .where((a) => privateHost(a.address));
    final host =
        testHost ?? (addresses.isEmpty ? null : addresses.first.address);
    if (host == null) {
      throw const ValidationException(message: 'simple.wifi_required');
    }
    final key = await algorithm.newSecretKey();
    final bytes = await key.extractBytes();
    final secret = base64UrlEncode(bytes);
    final authentication = base64UrlEncode((await Sha256().hash(bytes)).bytes);
    final id =
        List.generate(24, (_) => Random.secure().nextInt(16).toRadixString(16))
            .join();
    final box = await algorithm.encrypt(utf8.encode(contents), secretKey: key);
    final envelope = jsonEncode({
      'nonce': base64Encode(box.nonce),
      'cipher': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes)
    });
    final expires = DateTime.now().add(const Duration(minutes: 5));
    final server =
        await HttpServer.bind(testHost ?? InternetAddress.anyIPv4, 0);
    _server = server;
    server.listen((request) async {
      try {
        if (DateTime.now().isAfter(expires) ||
            request.method != 'GET' ||
            request.uri.path != '/$id' ||
            request.headers.value(HttpHeaders.authorizationHeader) !=
                'Bearer $authentication') {
          request.response.statusCode = HttpStatus.forbidden;
        } else {
          request.response.headers.contentType = ContentType.json;
          request.response.headers.set('Cache-Control', 'no-store');
          request.response.write(envelope);
        }
        await request.response.close();
      } catch (_) {
        request.response.close();
      }
    });
    _expiry = Timer(const Duration(minutes: 5), stop);
    final code = Uri(
            scheme: 'baseet',
            host: 'transfer',
            queryParameters: {
              'host': host,
              'port': server.port.toString(),
              'id': id
            },
            fragment: secret)
        .toString();
    return TransferSession(code, expires);
  }

  Future<String> receive(String code,
      {bool allowLoopbackForTesting = false}) async {
    final uri = Uri.tryParse(code.trim());
    final host = uri?.queryParameters['host'] ?? '';
    final port = int.tryParse(uri?.queryParameters['port'] ?? '');
    final id = uri?.queryParameters['id'] ?? '';
    if (uri == null ||
        uri.scheme != 'baseet' ||
        uri.host != 'transfer' ||
        (!privateHost(host) &&
            !(allowLoopbackForTesting && host == '127.0.0.1')) ||
        port == null ||
        port < 1 ||
        port > 65535 ||
        !RegExp(r'^[a-f0-9]{24}$').hasMatch(id)) {
      throw const ValidationException(message: 'simple.invalid_code');
    }
    List<int> secret;
    try {
      secret = base64Url.decode(uri.fragment);
    } catch (_) {
      throw const ValidationException(message: 'simple.invalid_code');
    }
    if (secret.length != 32) {
      throw const ValidationException(message: 'simple.invalid_code');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..findProxy = (_) => 'DIRECT';
    try {
      final request = await client
          .getUrl(Uri(scheme: 'http', host: host, port: port, path: '/$id'))
          .timeout(const Duration(seconds: 10));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.authorizationHeader,
          'Bearer ${base64UrlEncode((await Sha256().hash(secret)).bytes)}');
      final response =
          await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw const ValidationException(message: 'simple.transfer_failed');
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 20))) {
        bytes.addAll(chunk);
        if (bytes.length > 48 * 1024 * 1024) {
          throw const ValidationException(message: 'simple.invalid_backup');
        }
      }
      final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final box = SecretBox(base64Decode(map['cipher'] as String),
          nonce: base64Decode(map['nonce'] as String),
          mac: Mac(base64Decode(map['mac'] as String)));
      return utf8
          .decode(await algorithm.decrypt(box, secretKey: SecretKey(secret)));
    } finally {
      client.close(force: true);
    }
  }

  Future<void> stop() async {
    _expiry?.cancel();
    _expiry = null;
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }
}
