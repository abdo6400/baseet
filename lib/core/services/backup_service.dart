import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../config/database/local/app_database.dart';
import 'settings_service.dart';

class BackupService {
  final AppDatabase appDatabase;
  final SettingsService settingsService;

  BackupService({
    AppDatabase? database,
    required this.settingsService,
  }) : appDatabase = database ?? AppDatabase();

  /// Exports all application tables into a structured JSON backup file
  Future<String> createBackup({String? targetDirectory}) async {
    final db = await appDatabase.database;
    final Map<String, dynamic> backupData = {
      'version': 1,
      'app': 'Baseet POS',
      'createdAt': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{},
    };

    final tables = [
      'categories',
      'products',
      'customers',
      'debt_transactions',
      'orders',
      'order_items',
      'suppliers',
      'supplier_invoices',
      'supplier_invoice_items',
    ];

    for (final table in tables) {
      try {
        final rows = await db.query(table);
        (backupData['tables'] as Map<String, dynamic>)[table] = rows;
      } catch (_) {}
    }

    final jsonString = jsonEncode(backupData);
    final now = DateTime.now();
    final fileName = 'baseet_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';

    Directory dir;
    if (targetDirectory != null && targetDirectory.isNotEmpty) {
      dir = Directory(targetDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      final dbPath = await getDatabasesPath();
      dir = Directory(dbPath);
    }

    final filePath = '${dir.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsString(jsonString);

    await settingsService.setLastBackupDate(now.toIso8601String());
    return filePath;
  }

  /// Restores application data from a JSON backup file
  Future<bool> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('ملف النسخة الاحتياطية غير موجود');
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    final tablesData = data['tables'] as Map<String, dynamic>?;
    if (tablesData == null) {
      throw Exception('صيغة ملف النسخة الاحتياطية غير صالحة');
    }

    final db = await appDatabase.database;

    await db.transaction((txn) async {
      final tables = [
        'supplier_invoice_items',
        'supplier_invoices',
        'suppliers',
        'order_items',
        'orders',
        'debt_transactions',
        'customers',
        'products',
        'categories',
      ];

      for (final table in tables) {
        try {
          await txn.delete(table);
        } catch (_) {}
      }

      for (final entry in tablesData.entries) {
        final table = entry.key;
        final rows = entry.value as List<dynamic>?;
        if (rows != null) {
          for (final row in rows) {
            if (row is Map<String, dynamic>) {
              await txn.insert(
                table,
                row,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      }
    });

    return true;
  }

  /// Checks if automatic backup is due and runs it silently
  Future<void> performAutoBackupIfDue() async {
    if (!settingsService.autoBackupEnabled) return;
    final dir = settingsService.backupDirectoryPath;
    if (dir.isEmpty) return;

    final lastDateStr = settingsService.lastBackupDate;
    if (lastDateStr.isNotEmpty) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate);
        if (diff.inHours < 24) return; // Already backed up within last 24h
      }
    }

    try {
      await createBackup(targetDirectory: dir);
    } catch (_) {}
  }
}
