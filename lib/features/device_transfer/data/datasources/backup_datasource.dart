import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/error/exceptions.dart';
import '../../domain/entities/backup_snapshot.dart';

class BackupDataSource {
  static const tables = [
    'categories',
    'products',
    'customers',
    'orders',
    'order_items',
    'debt_transactions',
    'store_settings'
  ];
  static const maxBytes = 32 * 1024 * 1024;
  final AppDatabase database;
  final Directory documents;
  BackupDataSource(this.database, this.documents);
  Never invalid() =>
      throw const ValidationException(message: 'simple.invalid_backup');
  Future<BackupSnapshot> export() async {
    final db = await database.database;
    final data = await db.transaction((txn) async {
      final rows = <String, dynamic>{};
      for (final table in tables) {
        rows[table] = (await txn.query(table))
            .map((row) => Map<String, Object?>.from(row))
            .toList();
      }
      return rows;
    });
    final attachments = <String, String>{};
    var attachmentBytes = 0;
    for (final table in ['orders', 'debt_transactions']) {
      for (final row in data[table] as List) {
        final path = row['receiptPath'];
        if (path is String && await File(path).exists()) {
          final file = File(path);
          attachmentBytes += await file.length();
          if (attachmentBytes > maxBytes ~/ 2) invalid();
          final id = attachments.length.toString();
          attachments[id] = base64Encode(await file.readAsBytes());
          row['receiptPath'] = 'attachment:$id';
        } else {
          row['receiptPath'] = null;
        }
      }
    }
    return inspect(jsonEncode({
      'format': 'baseet',
      'version': 2,
      'createdAt': DateTime.now().toIso8601String(),
      'tables': data,
      'attachments': attachments
    }));
  }

  BackupSnapshot inspect(String contents) {
    try {
      if (utf8.encode(contents).length > maxBytes) invalid();
      final data = jsonDecode(contents) as Map<String, dynamic>;
      if (data['format'] != 'baseet' || data['version'] != 2) invalid();
      final rows = data['tables'] as Map<String, dynamic>;
      if (rows.length != tables.length ||
          tables.any(
              (t) => rows[t] is! List || (rows[t] as List).length > 100000)) {
        invalid();
      }
      final attachments = data['attachments'] as Map<String, dynamic>;
      for (final entry in attachments.entries) {
        if (!RegExp(r'^\d+$').hasMatch(entry.key) || entry.value is! String) {
          invalid();
        }
        base64Decode(entry.value as String);
      }
      for (final table in tables) {
        final ids = <String>{};
        for (final row in rows[table] as List) {
          if (row is! Map<String, dynamic>) invalid();
          final id = row[table == 'store_settings' ? 'key' : 'id'];
          if (id is! String || id.isEmpty || !ids.add(id)) invalid();
          for (final entry in row.entries) {
            final value = entry.value;
            if (value != null && value is! String && value is! num) invalid();
            if (value is num && (!value.isFinite || value < 0)) invalid();
          }
          final receipt = row['receiptPath'];
          if (receipt != null &&
              (receipt is! String ||
                  !receipt.startsWith('attachment:') ||
                  !attachments.containsKey(receipt.substring(11)))) {
            invalid();
          }
        }
      }
      final customers = {for (final row in rows['customers']) row['id']};
      final products = {for (final row in rows['products']) row['id']};
      final orders = {for (final row in rows['orders']) row['id']};
      final categories = {for (final row in rows['categories']) row['id']};
      for (final row in rows['products']) {
        if (!categories.contains(row['categoryId'])) invalid();
      }
      for (final row in rows['orders']) {
        if (row['customerId'] != null &&
            !customers.contains(row['customerId'])) {
          invalid();
        }
      }
      for (final row in rows['order_items']) {
        if (!orders.contains(row['orderId']) ||
            !products.contains(row['productId'])) {
          invalid();
        }
      }
      for (final row in rows['debt_transactions']) {
        if (!customers.contains(row['customerId'])) invalid();
      }
      return BackupSnapshot(
          contents: contents,
          createdAt: DateTime.parse(data['createdAt'] as String),
          products: (rows['products'] as List).length,
          customers: (rows['customers'] as List).length,
          invoices: (rows['orders'] as List).length);
    } catch (_) {
      invalid();
    }
  }

  Future<void> restore(BackupSnapshot snapshot) async {
    final verified = inspect(snapshot.contents);
    final data = jsonDecode(verified.contents) as Map<String, dynamic>;
    final rows = data['tables'] as Map<String, dynamic>;
    final db = await database.database;
    // Retain a recovery copy before replacing any local records.
    await documents.create(recursive: true);
    final safety = await export();
    await File(p.join(documents.path, 'before-transfer.baseet'))
        .writeAsString(safety.contents, flush: true);
    final folder = Directory(p.join(documents.path, 'receipts',
        '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 30)}'));
    await folder.create(recursive: true);
    try {
      final attachments = data['attachments'] as Map<String, dynamic>;
      for (final entry in attachments.entries) {
        await File(p.join(folder.path, entry.key))
            .writeAsBytes(base64Decode(entry.value as String), flush: true);
      }
      await db.transaction((txn) async {
        // Reject unknown columns before altering the database.
        for (final table in tables) {
          final columns = {
            for (final row in await txn.rawQuery('PRAGMA table_info($table)'))
              row['name']
          };
          for (final row in rows[table]) {
            if ((row as Map).keys.any((key) => !columns.contains(key))) {
              invalid();
            }
          }
        }
        for (final table in tables.reversed) {
          await txn.delete(table);
        }
        for (final table in tables) {
          for (final raw in rows[table]) {
            final row = Map<String, Object?>.from(raw as Map);
            if (row['receiptPath'] is String) {
              row['receiptPath'] = p.join(
                  folder.path, (row['receiptPath'] as String).substring(11));
            }
            await txn.insert(table, row);
          }
        }
      });
    } catch (_) {
      // Only remove the unique attachment folder created by this operation.
      await folder.delete(recursive: true);
      rethrow;
    }
  }
}
